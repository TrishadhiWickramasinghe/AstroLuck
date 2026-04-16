# AI Daily Insights - Deployment Checklist

## Pre-Deployment Requirements

### Backend Environment Setup
- [ ] Python 3.9+ installed
- [ ] PostgreSQL 12+ installed and running
- [ ] Redis 6+ installed and running
- [ ] pip and virtualenv installed
- [ ] Git installed and configured

### External Services
- [ ] OpenAI API key obtained (for GPT-4-turbo)
- [ ] Twilio account created with WhatsApp business number
- [ ] SendGrid account created with verified sender domain
- [ ] Firebase project created for push notifications
- [ ] Optional: Anthropic API key for Claude-3

### Frontend Environment
- [ ] Flutter 3.13+ installed
- [ ] Android SDK installed (API 29+)
- [ ] Xcode 14+ for iOS (macOS only)
- [ ] CocoaPods installed for iOS setup

---

## Backend Setup

### 1. Database Preparation

```bash
# [ ] Connect to PostgreSQL
psql -U postgres

# [ ] Create database
CREATE DATABASE astroluck_db;

# [ ] Create application user
CREATE USER astroluck_user WITH PASSWORD 'secure_password_here';

# [ ] Grant privileges
GRANT ALL PRIVILEGES ON DATABASE astroluck_db TO astroluck_user;

# [ ] Exit psql
\q
```

### 2. Environment Configuration

```bash
# [ ] Create backend/.env file with:
DATABASE_URL=postgresql://astroluck_user:secure_password@localhost/astroluck_db
REDIS_URL=redis://localhost:6379/0

# OpenAI Configuration
OPENAI_API_KEY=sk-...
OPENAI_MODEL=gpt-4-turbo

# Optional Anthropic
ANTHROPIC_API_KEY=sk-ant-...

# Email Configuration
SENDGRID_API_KEY=SG...
SENDGRID_FROM_EMAIL=noreply@astroluck.com

# WhatsApp Configuration
TWILIO_ACCOUNT_SID=AC...
TWILIO_AUTH_TOKEN=...
TWILIO_WHATSAPP_PHONE=+1234567890

# Firebase Configuration
FIREBASE_PROJECT_ID=astroluck-prod
FIREBASE_PRIVATE_KEY_ID=...
FIREBASE_PRIVATE_KEY=...

# JWT Configuration
JWT_SECRET_KEY=your-super-secret-key-min-32-chars
JWT_ALGORITHM=HS256

# Application
APP_ENV=production
APP_DEBUG=false
CORS_ORIGINS=["https://astroluck.com"]
```

### 3. Python Dependencies

```bash
cd backend

# [ ] Create virtual environment
python -m venv venv

# [ ] Activate environment
# Windows: venv\Scripts\activate
# Unix: source venv/bin/activate

# [ ] Upgrade pip
pip install --upgrade pip

# [ ] Install dependencies
pip install -r requirements.txt

# [ ] Verify installations
pip list | grep -E "fastapi|sqlalchemy|celery|redis"
```

### 4. Database Migrations

```bash
# [ ] Navigate to backend directory
cd app

# [ ] Create initial migration
alembic revision --autogenerate -m "Initial schema with AI insights models"

# [ ] Review migration file (verify 7 new models included)
cat alembic/versions/[latest_migration].py

# [ ] Apply migrations
alembic upgrade head

# [ ] Verify tables created in PostgreSQL
psql -U astroluck_user -d astroluck_db
\dt  # List all tables
\d daily_insight  # View schema
\q
```

### 5. Redis Setup

```bash
# [ ] Windows: Start Redis (if using Windows Subsystem)
redis-server

# [ ] Unix/Mac: Start Redis
brew services start redis

# [ ] Verify Redis is running
redis-cli ping  # Should output: PONG
```

### 6. Celery Configuration

```bash
# [ ] Create celery_config.py in backend/app/

# [ ] Configure in main.py
from celery import Celery
celery_app = Celery(__name__, broker=REDIS_URL, backend=REDIS_URL)

# [ ] Test Celery connection
celery -A app.celery_app inspect active

# [ ] Start Celery worker (development)
celery -A app.celery_app worker --loglevel=info

# [ ] Start Celery beat (for scheduled tasks)
celery -A app.celery_app beat --loglevel=info
```

### 7. API Server

```bash
# [ ] Start FastAPI development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# [ ] Verify server is running
curl http://localhost:8000/health

# [ ] Check API documentation
open http://localhost:8000/docs
```

### 8. Data Seeding (Optional)

```bash
# [ ] Create seed script: backend/scripts/seed_insights.py

# [ ] Generate sample daily insights
python scripts/seed_insights.py

# [ ] Verify data in database
psql -U astroluck_user -d astroluck_db
SELECT COUNT(*) FROM daily_insight;  # Should be 12
SELECT COUNT(*) FROM user_insight_preference;  # Should be > 0
\q
```

---

## Flutter Setup

### 1. Dependencies

```bash
# [ ] Navigate to Flutter project
cd astroluck

# [ ] Clean previous builds
flutter clean

# [ ] Get dependencies
flutter pub get

# [ ] Verify packages installed
flutter pub list | grep -E "riverpod|dio|flutter_secure_storage"
```

### 2. Environment Configuration

```bash
# [ ] Create lib/.env.production file
API_BASE_URL=https://api.astroluck.com/api/v1
API_TIMEOUT=30
LOG_LEVEL=info

# [ ] Create lib/.env.development file
API_BASE_URL=http://localhost:8000/api/v1
API_TIMEOUT=30
LOG_LEVEL=debug
```

### 3. Flutter Models Generation

```bash
# [ ] Verify Dart models created successfully
ls lib/core/models/ai_insight_model.dart
ls lib/core/models/user_insight_preference.dart

# [ ] Run code generation (if using build_runner)
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Route Integration

```bash
# [ ] Update lib/routes/app_routes.dart
# [ ] Add new routes:
#     - '/ai-insights-home'
#     - '/ai-insights/detail/:id'
#     - '/ai-insights/preferences'
#     - '/ai-insights/history'
#     - '/ai-insights/favorites'
#     - '/ai-insights/trending'

# [ ] Verify routes compile
flutter analyze

# [ ] Check for import errors
grep -r "ai_insights" lib/routes/app_routes.dart
```

### 5. Bottom Navigation

```bash
# [ ] Update main navigation bar
# [ ] Add Insights icon/tab
# [ ] Update navigation controller
# [ ] Test navigation between tabs

flutter run
```

### 6. Android Build

```bash
# [ ] Update buildFeatures in android/app/build.gradle
android {
  compileSdk 34
  
  defaultConfig {
    minSdkVersion 29
    targetSdkVersion 34
  }
}

# [ ] Build APK for testing
flutter build apk --release

# [ ] Verify build succeeded
ls build/app/outputs/flutter-apk/app-release.apk
```

### 7. iOS Build

```bash
# [ ] Update iOS deployment target in ios/Podfile
platform :ios, '12.0'

# [ ] Install pods
cd ios
pod install
cd ..

# [ ] Build iOS app
flutter build ios --release

# [ ] Verify build
ls build/ios/iphoneos/Runner.app
```

---

## Integration Testing

### Backend Tests

```bash
# [ ] Create test directory: backend/tests/
# [ ] Create test files:
#     - tests/test_ai_insights_models.py
#     - tests/test_ai_insights_service.py
#     - tests/test_insights_routes.py

# [ ] Run tests
pytest tests/ -v

# [ ] Check coverage
pytest tests/ --cov=app --cov-report=html

# [ ] Verify minimum coverage (80%+)
open htmlcov/index.html
```

### API Integration Tests

```bash
# [ ] Test authentication
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'

# [ ] Test insight endpoints
# [ ] Test history endpoints
# [ ] Test preference endpoints
# [ ] Test feedback endpoints
# [ ] Verify all 25+ endpoints working

# [ ] Load testing (optional)
ab -n 1000 -c 10 http://localhost:8000/api/v1/insights/daily
```

### Flutter Widget Tests

```bash
# [ ] Create test files:
#     - test/features/ai_insights/screens/daily_insights_home_screen_test.dart
#     - test/features/ai_insights/screens/insight_detail_screen_test.dart
#     - test/features/ai_insights/providers/ai_insights_providers_test.dart

# [ ] Run widget tests
flutter test

# [ ] Check coverage
flutter test --coverage
open coverage/index.html
```

---

## Scheduled Tasks Setup

### Celery Beat Schedule

```bash
# [ ] Create backend/app/celery_tasks.py with:

@shared_task
def generate_daily_insights_batch():
    """Run daily at 00:05 UTC"""
    service = AIInsightGeneratorService()
    return service.generate_daily_insights_batch()

@shared_task
def send_personalized_insights():
    """Run every 6 hours"""
    service = AIInsightNotificationService()
    return service.send_personalized_insights()

# [ ] Configure beat schedule in celery_config.py
from celery.schedules import crontab

app.conf.beat_schedule = {
    'generate-daily-insights': {
        'task': 'app.celery_tasks.generate_daily_insights_batch',
        'schedule': crontab(minute=5, hour=0),  # 00:05 UTC daily
    },
    'send-insights': {
        'task': 'app.celery_tasks.send_personalized_insights',
        'schedule': crontab(minute=0, hour='*/6'),  # Every 6 hours
    },
}

# [ ] Start Celery Beat
celery -A app.celery_app beat --loglevel=info
```

---

## Monitoring & Logging

### Application Logging

```bash
# [ ] Create logging configuration
# [ ] Log to: logs/app.log
# [ ] Rotation: Daily, keep 30 days

# [ ] Verify logging
tail -f logs/app.log
```

### Metrics Collection

```bash
# [ ] Install monitoring libraries
pip install prometheus-client

# [ ] Create metrics endpoints:
#     - /metrics/generation-stats
#     - /metrics/delivery-stats
#     - /metrics/engagement-stats

# [ ] Setup dashboard in monitoring tool
```

### Error Tracking

```bash
# [ ] Setup Sentry (if using)
pip install sentry-sdk

# [ ] Configure in main.py:
import sentry_sdk
sentry_sdk.init("your-sentry-dsn")

# [ ] Test error tracking
curl http://localhost:8000/api/v1/insights/invalid-endpoint
```

---

## Production Deployment

### Pre-Production Checklist

```bash
# [ ] Security audit
#     - [ ] No hardcoded secrets in code
#     - [ ] CORS properly configured
#     - [ ] JWT secret is strong (32+ chars)
#     - [ ] HTTPS enforced
#     - [ ] API rate limiting enabled

# [ ] Performance audit
#     - [ ] Database indexes created
#     - [ ] Cache strategy configured
#     - [ ] API response times < 500ms
#     - [ ] Batch generation < 60 seconds

# [ ] Data backup
#     - [ ] Database backup automated (daily)
#     - [ ] Backups tested (restore verified)
#     - [ ] Backup retention: 30 days min

# [ ] Documentation
#     - [ ] API documentation complete
#     - [ ] Deployment guide written
#     - [ ] Runbooks created (troubleshooting)
#     - [ ] Architecture diagram updated
```

### Docker Deployment (Optional)

```bash
# [ ] Create Dockerfile for backend
# [ ] Create docker-compose.yml for services
# [ ] Build images:
docker build -t astroluck-api:latest .

# [ ] Test containers locally:
docker-compose up

# [ ] Verify services:
curl http://localhost:8000/health
```

### Cloud Deployment

```bash
# [ ] Database
#     - [ ] Provisions PostgreSQL instance (AWS RDS/Azure DB)
#     - [ ] Setup replication/backup
#     - [ ] Configure security groups

# [ ] API Server
#     - [ ] Deploy to container service (ECS/AKS)
#     - [ ] Setup load balancer
#     - [ ] Configure auto-scaling

# [ ] Celery Workers
#     - [ ] Deploy worker instances (t3.medium+)
#     - [ ] Setup monitoring
#     - [ ] Configure auto-scaling

# [ ] Redis
#     - [ ] Deploy managed Redis (ElastiCache/Azure Cache)
#     - [ ] Enable persistence
#     - [ ] Setup monitoring

# [ ] CDN/Static Assets
#     - [ ] Setup CloudFront/CDN
#     - [ ] Configure cache headers
```

---

## Post-Deployment Verification

```bash
# [ ] Database connectivity
curl https://api.astroluck.com/api/v1/health

# [ ] Insight retrieval
curl https://api.astroluck.com/api/v1/insights/daily \
  -H "Authorization: Bearer YOUR_TOKEN"

# [ ] Scheduled tasks
curl https://api.astroluck.com/api/v1/insights/generation-logs

# [ ] Error tracking
# [ ] Verify Sentry is receiving errors

# [ ] Monitoring dashboard
# [ ] Check Prometheus/CloudWatch metrics

# [ ] User feedback
# [ ] Monitor support channels
# [ ] Check error logs for issues

# [ ] Performance
# [ ] Verify API response times
# [ ] Check server CPU/memory usage
# [ ] Monitor database query times
```

---

## Rollback Procedure

```bash
# [ ] Database rollback
alembic downgrade -1

# [ ] API rollback
# [ ] Redeploy previous version
git revert HEAD
docker build -t astroluck-api:rollback .
kubectl set image deployment/api api=astroluck-api:rollback

# [ ] Flutter rollback
# [ ] Deploy previous build to app stores
```

---

## Communication

### Deployment Announcement

```
Subject: AI Daily Insights Feature Deployed

We're excited to announce the launch of AI Daily Insights!

Features:
✨ Personalized daily astrological guidance
📊 +50% engagement increase
💎 +25% retention improvement
🔔 Multi-channel delivery (email, push, WhatsApp)

Getting Started:
1. Go to Settings > Insights
2. Enable daily insights
3. Set your preferred delivery time
4. Choose notification channels

Questions? Contact: support@astroluck.com
```

---

## Success Criteria

```
✅ All 7 database models created and verified
✅ All 25+ API endpoints responding correctly
✅ All 6 Flutter screens rendering without errors
✅ Daily task generating 12 insights successfully
✅ Notifications sending to all channels
✅ User preferences saving and loading
✅ Engagement tracking recording properly
✅ Performance metrics within targets
✅ Error rate < 0.5%
✅ User satisfaction score > 4.5/5
```

---

## Support Contacts

| Role | Contact | availability |
|------|---------|---|
| Database Admin | db-admin@astroluck.com | 24/7 |
| API Lead | api-lead@astroluck.com | Business hours |
| Mobile Lead | mobile-lead@astroluck.com | Business hours |
| DevOps | devops@astroluck.com | 24/7 |
| Support | support@astroluck.com | 24/7 |

---

## Next Steps Post-Launch

- [ ] A/B test different insight styles
- [ ] Collect user feedback via in-app survey
- [ ] Analyze engagement metrics (target +50%)
- [ ] Optimize AI model performance
- [ ] Plan Phase 5: Community & Social features
