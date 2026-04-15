# AstroLuck Python Backend

A FastAPI-based backend for the AstroLuck Flutter application. Provides cloud synchronization, user authentication, lucky number generation with advanced astrological calculations, community features, and analytics.

## Features

- **User Authentication**: JWT-based authentication with access/refresh tokens
- **Lucky Number Generation**: Advanced astrology and numerology calculations
- **Lottery History Tracking**: Store and analyze lottery plays with results
- **Analytics & Insights**: User statistics and success rate tracking
- **Community Features**: Share lucky numbers, leaderboard, likes/engagement
- **Cloud Sync**: Store user data, preferences, and history in the cloud
- **Admin Dashboard Ready**: Database structure supports admin analytics

## Technology Stack

- **FastAPI**: Modern, fast web framework
- **PostgreSQL**: Robust database
- **SQLAlchemy**: ORM for database operations
- **Alembic**: Database migrations
- **Pydantic**: Data validation and serialization
- **Python-Jose**: JWT token management
- **Passlib/Bcrypt**: Password hashing

## Project Structure

```
backend/
├── app/
│   ├── api/              # API endpoints/routes
│   │   ├── auth.py       # Authentication endpoints
│   │   ├── users.py      # User profile endpoints
│   │   └── community.py  # Community/sharing endpoints
│   ├── core/             # Core configurations
│   │   ├── config.py     # App settings
│   │   └── security.py   # Security utilities (JWT, hashing)
│   ├── db/               # Database configuration
│   ├── models/           # SQLAlchemy models
│   ├── schemas/          # Pydantic schemas (request/response)
│   ├── services/         # Business logic
│   │   ├── user_service.py       # User operations
│   │   └── lottery_service.py    # Lottery operations
│   ├── utils/            # Utility functions
│   │   ├── astrology.py  # Numerology, lottery, date utilities
│   │   └── common.py     # Common utilities
│   └── main.py           # FastAPI application
├── alembic/              # Database migrations
├── Dockerfile            # Docker image
├── docker-compose.yml    # Docker Compose setup
├── requirements.txt      # Python dependencies
├── .env.example         # Environment variables template
└── README.md            # This file
```

## Installation

### Prerequisites

- Python 3.9+
- PostgreSQL 14+
- Docker & Docker Compose (optional)

### Setup (Local)

1. **Clone/Extract the project**
```bash
cd backend
```

2. **Create virtual environment**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies**
```bash
pip install -r requirements.txt
```

4. **Setup environment**
```bash
cp .env.example .env
# Edit .env with your settings
```

5. **Setup PostgreSQL database**
```bash
# Create database
createdb astroluck_db

# Or use Docker:
docker run --name astroluck-postgres -e POSTGRES_PASSWORD=astroluck_password -e POSTGRES_DB=astroluck_db -p 5432:5432 -d postgres:15-alpine
```

6. **Run migrations**
```bash
alembic upgrade head
```

7. **Start the server**
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000` with interactive documentation at `http://localhost:8000/docs`

### Setup (Docker Compose)

```bash
# Start services
docker-compose up -d

# Run migrations
docker-compose exec backend alembic upgrade head

# View logs
docker-compose logs -f backend
```

## API Documentation

### Authentication Endpoints

#### Register
```
POST /api/v1/auth/register
{
  "email": "user@example.com",
  "username": "username",
  "password": "securepassword",
  "full_name": "John Doe"
}

Response:
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "token_type": "bearer"
}
```

#### Login
```
POST /api/v1/auth/login
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

#### Refresh Token
```
POST /api/v1/auth/refresh
{
  "token": "refresh_token_here"
}
```

### User Endpoints

#### Get Profile
```
GET /api/v1/users/me
Headers: Authorization: Bearer {access_token}
```

#### Update Profile
```
PUT /api/v1/users/me
Headers: Authorization: Bearer {access_token}
{
  "birth_date": "1990-08-20T00:00:00",
  "birth_time": "14:30",
  "birth_place": "New York",
  "latitude": 40.7128,
  "longitude": -74.0060,
  "gender": "M"
}
```

#### Generate Lucky Numbers
```
POST /api/v1/users/generate-lucky-numbers
Headers: Authorization: Bearer {access_token}
{
  "lottery_type": "6/49"
}

Response:
{
  "numbers": "7,23,45,29,8,41",
  "lottery_type": "6/49",
  "daily_lucky_number": 7,
  "life_path_number": 3,
  "lucky_color": "#FF6347",
  "energy_level": "High",
  "energy_value": 87,
  "lucky_time": "14:00",
  "timestamp": "2024-04-16T10:30:00"
}
```

#### Record Lottery Play
```
POST /api/v1/users/record-lottery
Headers: Authorization: Bearer {access_token}
{
  "lottery_type": "6/49",
  "numbers": "7,23,45,29,8,41",
  "daily_lucky_number": 7,
  "lucky_color": "#FF6347",
  "energy_level": "High"
}
```

#### Get Lottery History
```
GET /api/v1/users/lottery-history?limit=50&offset=0
Headers: Authorization: Bearer {access_token}
```

### Community Endpoints

#### Create Lucky Share
```
POST /api/v1/community/shares
Headers: Authorization: Bearer {access_token}
{
  "numbers": "7,23,45,29,8,41",
  "lottery_type": "6/49",
  "description": "Got these from today's cosmic alignment",
  "is_public": true
}
```

#### Get Public Shares
```
GET /api/v1/community/shares/public?limit=50&offset=0
```

#### Like a Share
```
POST /api/v1/community/shares/{share_id}/like
Headers: Authorization: Bearer {access_token}
```

#### Get Leaderboard
```
GET /api/v1/community/leaderboard?limit=50
```

## Supported Lottery Types

- **6/49**: Classic 6 from 49 numbers
- **Powerball**: 5 from 69 + Powerball (1-26)
- **Megamillions**: 5 from 70 + Megaball (1-25)
- **4-Digit**: 4 digits (0-9, repeats allowed)
- **3-Digit**: 3 digits (0-9, repeats allowed)
- **Euromillions**: 5 from 50 + 2 stars (1-12)

## Environment Variables

```
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/astroluck_db

# Security
SECRET_KEY=your-secret-key-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7

# App
DEBUG=false
APP_ENV=production
API_V1_STR=/api/v1
PROJECT_NAME=AstroLuck Backend

# CORS
CORS_ORIGINS=["https://yourdomain.com"]
```

## Database Models

### User
```
- id (PK)
- email (unique)
- username (unique)
- hashed_password
- full_name
- gender
- birth_date
- birth_time
- birth_place
- latitude / longitude
- is_active
- is_verified
- created_at / updated_at
```

### LotteryHistory
```
- id (PK)
- user_id (FK)
- lottery_type
- numbers
- generated_at
- life_path_number
- daily_lucky_number
- lucky_color
- energy_level
- result_numbers
- matched_count
- prize_amount
- created_at / updated_at
```

### UserAnalytics
```
- id (PK)
- user_id (FK, unique)
- total_plays
- total_winners
- total_winnings
- favorite_lottery_type
- most_used_numbers
- success_rate
- created_at / updated_at
```

### LuckyShare
```
- id (PK)
- user_id (FK)
- numbers
- lottery_type
- description
- likes_count
- comments_count
- is_public
- created_at / updated_at
```

## Astrological Formulas

### Life Path Number
Sum all digits of birth date, reduce to single digit (1-9)
```
Example: 1990-08-20 → 1+9+9+0+0+8+2+0 = 29 → 2+9 = 11 → 1+1 = 2
```

### Daily Lucky Number
```
Formula: (Life Path + Day + Month + Year) % 9
If result is 0, return 9
Changes daily
```

### Destiny Number
Letter-to-number mapping of full name (A=1, B=2, ..., Z=26)

### Lottery Number Generation
```
Formula: (Daily Lucky Number × Multiplier) % MaxRange
Multipliers: [3, 5, 7, 9, 11]
```

### Energy Level
Combines daily lucky number, life path, and moon phase
- High: 70-100
- Medium: 40-69
- Low: 0-39

## Development

### Running Tests (Future)
```bash
pytest tests/
```

### Database Migrations

Create a new migration:
```bash
alembic revision --autogenerate -m "description"
```

Apply migrations:
```bash
alembic upgrade head
```

### Code Format & Linting (Future)
```bash
black app/
flake8 app/
```

## Deployment

### Production Checklist

- [ ] Change `SECRET_KEY` in production
- [ ] Set `DEBUG=false`
- [ ] Update `CORS_ORIGINS` with your domain
- [ ] Use strong PostgreSQL password
- [ ] Setup HTTPS/SSL
- [ ] Configure proper logging
- [ ] Setup monitoring & alerts
- [ ] Backup database regularly
- [ ] Use environment variables (not hardcoded)

### Deploy to Heroku

```bash
heroku create astroluck-backend
heroku addons:create heroku-postgresql:standard-0
git push heroku main
heroku run alembic upgrade head
```

### Deploy with Docker

```bash
docker build -t astroluck-backend .
docker run -e DATABASE_URL=your_db_url -p 8000:8000 astroluck-backend
```

## Integration with Flutter App

### Configuration

Update your Flutter app's `constants.ts` or similar:

```dart
const String API_BASE_URL = 'https://your-backend.com/api/v1';
```

### Example Usage in Flutter

```dart
// Register
final response = await http.post(
  Uri.parse('$API_BASE_URL/auth/register'),
  body: jsonEncode({
    'email': email,
    'username': username,
    'password': password,
  }),
);

// Generate Lucky Numbers
final response = await http.post(
  Uri.parse('$API_BASE_URL/users/generate-lucky-numbers'),
  headers: {'Authorization': 'Bearer $accessToken'},
  body: jsonEncode({'lottery_type': '6/49'}),
);
```

## Support & Contributing

For issues, bugs, or feature requests, please open an issue on GitHub.

## License

Copyright © 2024 AstroLuck. All rights reserved.

---

**Last Updated**: April 16, 2024
