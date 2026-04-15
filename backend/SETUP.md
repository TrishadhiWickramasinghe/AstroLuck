# Development Setup Guide

## Quick Start

### Option 1: Docker Compose (Recommended)

```bash
# Start all services (PostgreSQL + Backend)
docker-compose up -d

# View logs
docker-compose logs -f backend

# Stop services
docker-compose down
```

### Option 2: Manual Setup

#### Prerequisites
- Python 3.9+
- PostgreSQL 14+

#### Linux/Mac
```bash
# 1. Run setup script
chmod +x setup.sh
./setup.sh

# 2. Update .env with your database credentials
nano .env

# 3. Create database in PostgreSQL
createdb astroluck_db

# 4. Start the server
uvicorn app.main:app --reload
```

#### Windows
```bash
# 1. Run setup script
setup.bat

# 2. Update .env with your database credentials

# 3. Create database in PostgreSQL
createdb astroluck_db

# 4. Start the server
uvicorn app.main:app --reload
```

## Database Setup

### PostgreSQL Installation

**Windows:**
```bash
# Download from https://www.postgresql.org/download/windows/
# Or use Chocolatey:
choco install postgresql
```

**Mac:**
```bash
brew install postgresql
brew services start postgresql
```

**Linux:**
```bash
sudo apt-get install postgresql postgresql-contrib
sudo systemctl start postgresql
```

### Create Database

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database and user
CREATE USER astroluck_user WITH PASSWORD 'astroluck_password';
CREATE DATABASE astroluck_db OWNER astroluck_user;
GRANT ALL PRIVILEGES ON DATABASE astroluck_db TO astroluck_user;
\q
```

Or use Docker:
```bash
docker run --name astroluck-postgres \
  -e POSTGRES_USER=astroluck_user \
  -e POSTGRES_PASSWORD=astroluck_password \
  -e POSTGRES_DB=astroluck_db \
  -p 5432:5432 \
  -d postgres:15-alpine
```

## Running Migrations

```bash
# Make sure virtual environment is activated

# Create tables
alembic upgrade head

# Check status
alembic current

# Create new migration (if needed)
alembic revision --autogenerate -m "description"
```

## Development Workflow

### 1. Activate Virtual Environment

**Linux/Mac:**
```bash
source venv/bin/activate
```

**Windows:**
```bash
venv\Scripts\activate.bat
```

### 2. Start Server with Auto-reload

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 3. Access API Documentation

- Interactive Docs (Swagger UI): http://localhost:8000/docs
- Alternative Docs (ReDoc): http://localhost:8000/redoc

### 4. Run Tests (Future)

```bash
# Install test dependencies
pip install pytest pytest-asyncio httpx

# Run tests
pytest
```

## Database Backup & Restore

### Backup

**PostgreSQL:**
```bash
pg_dump -U astroluck_user astroluck_db > backup.sql
```

**Docker:**
```bash
docker exec astroluck-postgres pg_dump -U astroluck_user astroluck_db > backup.sql
```

### Restore

**PostgreSQL:**
```bash
psql -U astroluck_user astroluck_db < backup.sql
```

**Docker:**
```bash
cat backup.sql | docker exec -i astroluck-postgres psql -U astroluck_user astroluck_db
```

## Troubleshooting

### Database Connection Error

```
Error: could not translate host name "localhost" to address: nodename nor servname provided
```

**Solution:** Make sure PostgreSQL is running
```bash
# Linux
sudo systemctl status postgresql

# Mac
brew services list

# Windows
# Check Windows Services for PostgreSQL
```

### Port Already in Use

```
ERROR: Application startup failed: [Errno 48] Address already in use
```

**Solution:** Use a different port
```bash
uvicorn app.main:app --port 8001 --reload
```

### Module Not Found Error

```
ModuleNotFoundError: No module named 'app'
```

**Solution:** Make sure you're in the backend directory and venv is activated
```bash
cd backend
source venv/bin/activate
```

### Import Error with Environment Variables

```
Error loading settings from .env
```

**Solution:** Copy example and update:
```bash
cp .env.example .env
# Edit .env with correct settings
```

## Code Quality

### Format Code (Future)

```bash
# Install black
pip install black

# Format all Python files
black app/
```

### Lint Code (Future)

```bash
# Install flake8
pip install flake8

# Check for issues
flake8 app/
```

## Performance Tips

1. **Use indexes** on frequently queried fields (done in models)
2. **Connection pooling** is handled by SQLAlchemy
3. **Enable query caching** for repeated queries
4. **Use pagination** for large result sets

Example pagination:
```python
@app.get("/users/lottery-history")
def get_history(limit: int = 50, offset: int = 0):
    # Pagination reduces memory usage and improves response time
    return db.query(LotteryHistory).limit(limit).offset(offset).all()
```

## Production Deployment

### Security Checklist

- [ ] Change `SECRET_KEY` in `.env`
- [ ] Set `DEBUG=false`
- [ ] Update `CORS_ORIGINS` with your domain
- [ ] Use strong PostgreSQL password
- [ ] Enable HTTPS/SSL
- [ ] Setup rate limiting
- [ ] Add API authentication headers
- [ ] Enable CSRF protection
- [ ] Setup logging & monitoring
- [ ] Regular database backups

### Environment Setup

Update `.env` for production:

```env
DEBUG=false
APP_ENV=production
SECRET_KEY=your-very-long-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7

# Use production database URL
DATABASE_URL=postgresql://username:password@production-db.com:5432/astroluck_db

# Update CORS origins
CORS_ORIGINS=["https://yourdomain.com", "https://app.yourdomain.com"]
```

### Deploy Commands

```bash
# Update dependencies to latest stable versions
pip install --upgrade -r requirements.txt

# Run migrations
alembic upgrade head

# Start production server
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
```

---

**Need Help?** Check the main [README.md](README.md) for API documentation and other details.
