# AstroLuck Production Deployment Guide

Complete guide for deploying AstroLuck to production environment.

## Table of Contents

1. [Pre-Deployment Checklist](#pre-deployment-checklist)
2. [Environment Setup](#environment-setup)
3. [Database Migration](#database-migration)
4. [Docker Setup](#docker-setup)
5. [Cloud Deployment (AWS/Heroku/GCP)](#cloud-deployment)
6. [Monitoring & Logging](#monitoring--logging)
7. [Security Hardening](#security-hardening)
8. [Scaling Strategy](#scaling-strategy)
9. [CI/CD Pipeline](#cicd-pipeline)
10. [Rollback Procedures](#rollback-procedures)

---

## Pre-Deployment Checklist

### Code Quality
- [ ] All tests passing (100% pass rate)
- [ ] No major security vulnerabilities
- [ ] Code coverage minimum 80%
- [ ] All linting issues resolved
- [ ] Dependencies up to date

### Configuration
- [ ] Environment variables defined
- [ ] API keys secured in secrets manager
- [ ] CORS configured correctly
- [ ] Rate limiting configured
- [ ] Logging configured

### Database
- [ ] PostgreSQL setup complete
- [ ] Database migrations tested
- [ ] Backup strategy defined
- [ ] Connection pooling configured
- [ ] Indexes created for performance

### Security
- [ ] SSL/TLS certificates ready
- [ ] JWT secrets rotated
- [ ] API key encryption enabled
- [ ] SQL injection prevention verified
- [ ] CSRF protection enabled

### Load Testing
- [ ] Backend stress tested
- [ ] Database stress tested
- [ ] CDN configured for static assets
- [ ] Rate limiting tested
- [ ] Failover tested

---

## Environment Setup

### 1. Production Environment Variables

Create `.env.production`:

```bash
# Application
DEBUG=False
ENVIRONMENT=production
LOG_LEVEL=INFO

# Database
DATABASE_URL=postgresql://user:password@prod-db-host:5432/astroluck_prod
DATABASE_POOL_SIZE=20
DATABASE_POOL_RECYCLE=3600

# API Config
API_HOST=0.0.0.0
API_PORT=8000
API_WORKERS=4
API_TIMEOUT=30

# Authentication
SECRET_KEY=your-super-secret-production-key-min-32-chars
JWT_ALGORITHM=HS256
JWT_EXPIRATION_HOURS=24
JWT_REFRESH_EXPIRATION_DAYS=7

# Email Service (SendGrid)
SENDGRID_API_KEY=SG.xxxxxxxxxxxx
SENDGRID_FROM_EMAIL=noreply@astroluck.com
SENDGRID_FROM_NAME=AstroLuck

# SMS Service (Twilio)
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxx
TWILIO_PHONE_NUMBER=+1234567890

# Payment Service (Stripe)
STRIPE_SECRET_KEY=sk_live_xxxxxxxxxxxxx
STRIPE_PUBLISHABLE_KEY=pk_live_xxxxxxxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx

# Cloud Storage (AWS S3)
AWS_ACCESS_KEY_ID=xxxxxxxxxxxx
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxx
AWS_STORAGE_BUCKET_NAME=astroluck-prod
AWS_S3_REGION=us-east-1

# Monitoring
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
NEW_RELIC_LICENSE_KEY=xxxxxxxxxxxx

# Analytics
GOOGLE_ANALYTICS_ID=UA-xxxxxxxxxxxxx

# CORS
CORS_ORIGINS=https://astroluck.com,https://www.astroluck.com

# Redis (for caching)
REDIS_URL=redis://prod-redis-host:6379/0
REDIS_CACHE_TTL=3600

# Backup
BACKUP_ENABLED=True
BACKUP_SCHEDULE=0 2 * * *  # Daily at 2 AM UTC
BACKUP_RETENTION_DAYS=30
```

### 2. Install System Dependencies

```bash
# Ubuntu 20.04+
sudo apt-get update
sudo apt-get install -y \
    python3.10 \
    python3.10-venv \
    postgresql-13 \
    postgresql-contrib \
    redis-server \
    nginx \
    certbot \
    python3-certbot-nginx \
    awscli
```

### 3. Setup PostgreSQL

```bash
# Create production database
sudo -u postgres psql

CREATE DATABASE astroluck_prod;
CREATE USER astroluck_user WITH PASSWORD 'strong-password-here';
ALTER ROLE astroluck_user SET client_encoding TO 'utf8';
ALTER ROLE astroluck_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE astroluck_user SET default_transaction_deferrable TO on;
ALTER ROLE astroluck_user SET default_time_zone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE astroluck_prod TO astroluck_user;
\q
```

### 4. Setup Redis

```bash
# Start Redis
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Test connection
redis-cli ping
```

---

## Database Migration

### 1. Create Migration Script

File: `migration_prod.py`

```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os
from app.models import Base

def migrate_database():
    """Migrate database schema to production"""
    
    # Get production database URL
    db_url = os.getenv('DATABASE_URL')
    
    # Create engine with connection pooling
    engine = create_engine(
        db_url,
        pool_size=20,
        max_overflow=0,
        pool_pre_ping=True,
        echo=False
    )
    
    # Create all tables
    Base.metadata.create_all(engine)
    
    # Create indexes
    with engine.connect() as conn:
        # Performance indexes
        conn.execute('''
        CREATE INDEX IF NOT EXISTS idx_user_email ON users(email);
        CREATE INDEX IF NOT EXISTS idx_lottery_user_date ON lottery_history(user_id, created_at);
        CREATE INDEX IF NOT EXISTS idx_insight_user_date ON daily_insights(user_id, created_at);
        CREATE INDEX IF NOT EXISTS idx_pool_status ON lottery_pools(status);
        CREATE INDEX IF NOT EXISTS idx_challenge_status ON challenges(status);
        ''')
        conn.commit()
    
    print("✓ Database migration complete")

if __name__ == '__main__':
    migrate_database()
```

### 2. Run Migration

```bash
cd /var/www/astroluck
source venv/bin/activate
python migration_prod.py
```

### 3. Backup Before Migration

```bash
# Backup existing PostgreSQL database
pg_dump -U astroluck_user astroluck_prod > backup_$(date +%Y%m%d).sql

# Compress backup
gzip backup_*.sql
```

---

## Docker Setup

### 1. Dockerfile

File: `Dockerfile`

```dockerfile
FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app ./app
COPY run.py .

# Create non-root user
RUN useradd -m -u 1000 astroluck && chown -R astroluck:astroluck /app
USER astroluck

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/health')"

# Run application
CMD ["gunicorn", "--workers", "4", "--worker-class", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000", "app.main:app"]
```

### 2. Docker Compose (Prod)

File: `docker-compose.prod.yml`

```yaml
version: '3.8'

services:
  api:
    build: .
    container_name: astroluck-api
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://astroluck_user:password@postgres:5432/astroluck_prod
      - ENVIRONMENT=production
      - DEBUG=False
    depends_on:
      - postgres
      - redis
    volumes:
      - ./logs:/app/logs
    restart: always
    networks:
      - astroluck-network
    
  postgres:
    image: postgres:13-alpine
    container_name: astroluck-db
    environment:
      - POSTGRES_DB=astroluck_prod
      - POSTGRES_USER=astroluck_user
      - POSTGRES_PASSWORD=strong-password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: always
    networks:
      - astroluck-network
    
  redis:
    image: redis:7-alpine
    container_name: astroluck-cache
    restart: always
    networks:
      - astroluck-network

  nginx:
    image: nginx:alpine
    container_name: astroluck-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - api
    restart: always
    networks:
      - astroluck-network

volumes:
  postgres_data:

networks:
  astroluck-network:
    driver: bridge
```

### 3. Build and Push to Registry

```bash
# Build image
docker build -t astroluck-api:1.0.0 .

# Tag for registry (AWS ECR example)
docker tag astroluck-api:1.0.0 123456789.dkr.ecr.us-east-1.amazonaws.com/astroluck-api:1.0.0

# Push to registry
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789.dkr.ecr.us-east-1.amazonaws.com
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/astroluck-api:1.0.0
```

---

## Cloud Deployment

### Option 1: AWS EC2 + RDS + ElastiCache

#### 1. Launch EC2 Instance

```bash
# Security Group Rules
- Allow 22 (SSH)
- Allow 80 (HTTP)
- Allow 443 (HTTPS)
- Allow 8000 (Application - internal)

# User Data Script
#!/bin/bash
sudo apt-get update
sudo apt-get install -y python3.10 python3.10-venv git nginx certbot python3-certbot-nginx

# Setup application
cd /var/www
git clone https://github.com/yourusername/astroluck.git
cd astroluck/backend
python3.10 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

#### 2. RDS PostgreSQL Setup

```bash
# Create RDS instance
aws rds create-db-instance \
    --db-instance-identifier astroluck-prod \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --master-username astroluck_user \
    --master-user-password 'strong-password' \
    --allocated-storage 20 \
    --backup-retention-period 30 \
    --multi-az
```

#### 3. ElastiCache Redis Setup

```bash
aws elasticache create-cache-cluster \
    --cache-cluster-id astroluck-cache \
    --cache-node-type cache.t3.micro \
    --engine redis \
    --num-cache-nodes 1
```

### Option 2: Heroku Deployment

#### 1. Create Procfile

```
web: gunicorn --workers 4 --worker-class uvicorn.workers.UvicornWorker app.main:app
release: python migration_prod.py
```

#### 2. Create runtime.txt

```
python-3.10.10
```

#### 3. Deploy

```bash
heroku login
heroku create astroluck-api
heroku config:set ENVIRONMENT=production
heroku config:set DATABASE_URL=postgresql://...
heroku config:set SECRET_KEY=...
# Add all other environment variables

git push heroku main
heroku run python migration_prod.py
```

### Option 3: Google Cloud Run

#### 1. Create cloudbuild.yaml

```yaml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/astroluck-api', '.']
  
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/astroluck-api']
  
  - name: 'gcr.io/cloud-builders/gke-deploy'
    args:
      - 'run'
      - '--filename=k8s/'
      - '--image=gcr.io/$PROJECT_ID/astroluck-api'
      - '--location=us-central1'
      - '--cluster=astroluck-prod'

images:
  - gcr.io/$PROJECT_ID/astroluck-api
```

#### 2. Deploy to Cloud Run

```bash
gcloud run deploy astroluck-api \
    --source . \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --set-env-vars DATABASE_URL=postgresql://...
```

---

## Monitoring & Logging

### 1. Setup Sentry for Error Tracking

File: `app/middleware/sentry.py`

```python
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration
from sentry_sdk.integrations.sqlalchemy import SqlalchemyIntegration
import os

def setup_sentry():
    """Initialize Sentry for error tracking"""
    sentry_dsn = os.getenv('SENTRY_DSN')
    
    if sentry_dsn:
        sentry_sdk.init(
            dsn=sentry_dsn,
            integrations=[
                FastApiIntegration(),
                SqlalchemyIntegration(),
            ],
            traces_sample_rate=0.1,
            environment=os.getenv('ENVIRONMENT', 'production'),
        )
```

### 2. Structured Logging

File: `app/utils/logger.py`

```python
import logging
import json
from datetime import datetime

class StructuredLogger:
    """Structured logging for production"""
    
    def __init__(self, name):
        self.logger = logging.getLogger(name)
    
    def log_event(self, event_type, **kwargs):
        """Log structured event"""
        event = {
            'timestamp': datetime.utcnow().isoformat(),
            'event_type': event_type,
            **kwargs
        }
        self.logger.info(json.dumps(event))

# Usage
logger = StructuredLogger(__name__)
logger.log_event('user_signup', user_id='123', email='user@example.com')
```

### 3. Metrics Collection

File: `app/middleware/metrics.py`

```python
from prometheus_client import Counter, Histogram, start_http_server
import time

# Define metrics
request_count = Counter(
    'api_requests_total',
    'Total API requests',
    ['method', 'endpoint', 'status']
)

request_duration = Histogram(
    'api_request_duration_seconds',
    'API request duration',
    ['method', 'endpoint']
)

def setup_prometheus():
    """Start Prometheus metrics server"""
    start_http_server(8001)  # Metrics on port 8001

async def prometheus_middleware(request, call_next):
    """Track request metrics"""
    start_time = time.time()
    
    response = await call_next(request)
    
    duration = time.time() - start_time
    request_count.labels(
        method=request.method,
        endpoint=request.url.path,
        status=response.status_code
    ).inc()
    
    request_duration.labels(
        method=request.method,
        endpoint=request.url.path
    ).observe(duration)
    
    return response
```

---

## Security Hardening

### 1. HTTPS with Let's Encrypt

```bash
sudo certbot certonly --nginx -d api.astroluck.com

# Auto-renewal
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer
```

### 2. Nginx Configuration

File: `nginx.conf`

```nginx
upstream astroluck_api {
    server 127.0.0.1:8000;
}

server {
    listen 80;
    server_name api.astroluck.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.astroluck.com;

    ssl_certificate /etc/letsencrypt/live/api.astroluck.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.astroluck.com/privkey.pem;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=100r/m;
    limit_req zone=api burst=20 nodelay;

    location / {
        proxy_pass http://astroluck_api;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering off;
    }

    location /health {
        proxy_pass http://astroluck_api;
        access_log off;
    }
}
```

### 3. JWT Secret Rotation

File: `app/utils/security.py`

```python
import os
import base64
from datetime import datetime, timedelta

class SecretRotation:
    """Manage JWT secret rotation"""
    
    ROTATION_INTERVAL = 90  # days
    
    @staticmethod
    def generate_secret():
        """Generate new secret"""
        return base64.urlsafe_b64encode(os.urandom(32)).decode()
    
    @staticmethod
    def rotate_secrets():
        """Rotate secrets if needed"""
        last_rotation = datetime.fromisoformat(
            os.getenv('SECRET_LAST_ROTATION', datetime.now().isoformat())
        )
        
        if (datetime.now() - last_rotation).days > SecretRotation.ROTATION_INTERVAL:
            new_secret = SecretRotation.generate_secret()
            os.environ['SECRET_KEY'] = new_secret
            os.environ['SECRET_LAST_ROTATION'] = datetime.now().isoformat()
            print("✓ Secrets rotated successfully")
```

---

## Scaling Strategy

### 1. Horizontal Scaling

```python
# Load balancer configuration (AWS ELB)
aws elb create-load-balancer \
    --load-balancer-name astroluck-api-lb \
    --listeners \
        InstancePort=8000,LoadBalancerPort=443,Protocol=https,SSLCertificateId=arn:aws:iam::...
```

### 2. Auto-Scaling Group

```bash
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name astroluck-api-asg \
    --launch-configuration-name astroluck-api-lc \
    --min-size 2 \
    --max-size 10 \
    --desired-capacity 3 \
    --load-balancer-names astroluck-api-lb
```

### 3. Database Connection Pooling

```python
from sqlalchemy.pool import QueuePool

engine = create_engine(
    DATABASE_URL,
    poolclass=QueuePool,
    pool_size=20,
    max_overflow=40,
    pool_pre_ping=True,
    pool_recycle=3600,
    echo_pool=False
)
```

---

## CI/CD Pipeline

### 1. GitHub Actions Workflow

File: `.github/workflows/deploy.yml`

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_PASSWORD: postgres
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
        with:
          python-version: '3.10'
      - run: pip install -r requirements.txt
      - run: pytest --cov=app

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to production
        run: |
          curl -X POST ${{ secrets.DEPLOY_WEBHOOK }} \
            -H "Authorization: Bearer ${{ secrets.DEPLOY_TOKEN }}"
```

### 2. Pre-Deployment Checks

File: `scripts/pre_deploy_check.py`

```python
#!/usr/bin/env python3
"""Pre-deployment verification checklist"""

import subprocess
import sys

def run_checks():
    checks = [
        ("Unit Tests", "pytest --cov=app --cov-fail-under=80"),
        ("Linting", "flake8 app --max-line-length=100"),
        ("Type Checking", "mypy app"),
        ("Security Check", "bandit -r app"),
        ("Database Migration", "python migration_prod.py --dry-run"),
    ]
    
    failed = []
    for check_name, command in checks:
        print(f"Running {check_name}... ", end="", flush=True)
        try:
            subprocess.run(command.split(), check=True, capture_output=True)
            print("✓")
        except subprocess.CalledProcessError:
            print("✗")
            failed.append(check_name)
    
    if failed:
        print(f"\n✗ Failed checks: {', '.join(failed)}")
        sys.exit(1)
    
    print("\n✓ All checks passed! Ready for deployment.")

if __name__ == '__main__':
    run_checks()
```

---

## Rollback Procedures

### 1. Database Rollback

```bash
# Rollback to previous version
pg_restore -U astroluck_user -d astroluck_prod backup_20240115.sql.gz

# Verify rollback
psql -U astroluck_user -d astroluck_prod -c "SELECT version() FROM schema_version;"
```

### 2. Application Rollback

```bash
# Using Docker
docker pull astroluck-api:1.0.0  # Previous version
docker-compose up -d

# Using Heroku
heroku releases
heroku rollback v25  # Previous version
```

### 3. Database Migration Rollback

File: `migration_rollback.py`

```python
from sqlalchemy import create_engine
from app.models import Base

def rollback_database():
    """Rollback to previous schema version"""
    db_url = os.getenv('DATABASE_URL')
    engine = create_engine(db_url)
    
    # Drop all tables
    Base.metadata.drop_all(engine)
    
    # Re-create base schema
    Base.metadata.create_all(engine)
    
    # Restore from backup
    subprocess.run([
        'pg_restore',
        '-U', os.getenv('DB_USER'),
        '-d', os.getenv('DB_NAME'),
        'backup_latest.sql'
    ])

if __name__ == '__main__':
    rollback_database()
```

---

## Deployment Checklist

- [ ] All tests passing (100%)
- [ ] Code review approved
- [ ] Environment variables configured
- [ ] Database migrations tested
- [ ] SSL certificates installed
- [ ] Monitoring configured (Sentry, Prometheus)
- [ ] Logging configured
- [ ] Backup configured
- [ ] Load testing completed
- [ ] Security scan passed
- [ ] Documentation updated
- [ ] Team notified
- [ ] Rollback plan ready

**After Deployment:**
- [ ] Health checks passing
- [ ] All endpoints responding
- [ ] No error rate spike
- [ ] Database queries optimized
- [ ] Monitoring dashboards live
- [ ] Team monitoring for 24 hours

---

**Last Updated:** 2024-01-15
**Version:** 1.0
