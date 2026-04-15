# AstroLuck Backend - Complete API Documentation

## Overview

The AstroLuck backend is a comprehensive FastAPI application featuring lottery number generation, community features, subscriptions, astrologer consultations, and more.

## Environment Setup

### Required Environment Variables

```bash
# Database
DATABASE_URL=sqlite:///./astroluck.db

# JWT
SECRET_KEY=your-secret-key-here
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_MINUTES=10080

# CORS
CORS_ORIGINS=["http://localhost:3000","http://localhost:8081"]

# Email Notifications (SendGrid)
SENDGRID_API_KEY=your-sendgrid-api-key
SENDGRID_FROM_EMAIL=noreply@astroluck.com

# SMS & WhatsApp (Twilio)
TWILIO_ACCOUNT_SID=your-twilio-account-id
TWILIO_AUTH_TOKEN=your-twilio-auth-token
TWILIO_PHONE_NUMBER=+1234567890
TWILIO_WHATSAPP_NUMBER=+1234567890

# Payments (Stripe)
STRIPE_SECRET_KEY=your-stripe-secret-key
STRIPE_PUBLISHABLE_KEY=your-stripe-publishable-key

# APScheduler
SCHEDULER_JOB_STORE=memory
```

## API Endpoints

### 1. Authentication Endpoints

#### Register
```
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "username": "johndoe",
  "password": "SecurePassword123!",
  "full_name": "John Doe"
}
```

**Response:**
```json
{
  "status": "success",
  "user_id": "uuid-here",
  "access_token": "jwt-token",
  "refresh_token": "refresh-token",
  "token_type": "bearer"
}
```

#### Login
```
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

### 2. User Profile Endpoints

#### Get Current User
```
GET /api/v1/users/me
Authorization: Bearer {token}
```

#### Update Profile
```
PUT /api/v1/users/me
Authorization: Bearer {token}
Content-Type: application/json

{
  "full_name": "John Doe",
  "birth_date": "1990-05-15",
  "birth_time": "14:30",
  "birth_place": "New York, USA",
  "latitude": 40.7128,
  "longitude": -74.0060,
  "gender": "Male",
  "phone_number": "+1234567890"
}
```

### 3. Daily Insights Endpoints

#### Generate Daily Insight
```
POST /api/v1/insights/generate
Authorization: Bearer {token}
```

**Response:**
```json
{
  "status": "success",
  "insight": {
    "date": "2024-01-15",
    "insight_text": "Aries energy runs high today!...",
    "lucky_hours": "5am-7am, 1pm-3pm",
    "best_activities": "Launch projects, increase activity...",
    "warning": null,
    "recommendations": [
      "Play your favorite lottery type today",
      "Mix even and odd numbers for balance"
    ]
  }
}
```

#### Get Today's Insight
```
GET /api/v1/insights/today
Authorization: Bearer {token}
```

#### Get Insight History
```
GET /api/v1/insights/history?days=7
Authorization: Bearer {token}
```

#### Get Weekly Summary
```
GET /api/v1/insights/weekly
Authorization: Bearer {token}
```

### 4. Achievements & Badges Endpoints

#### Get Achievements
```
GET /api/v1/achievements
Authorization: Bearer {token}
```

**Response:**
```json
{
  "status": "success",
  "total_badges": 5,
  "total_points": 350,
  "newly_unlocked": {
    "count": 1,
    "badges": [
      {
        "badge_name": "Lucky Streak",
        "badge_icon": "⭐",
        "description": "Played 10 lotteries",
        "points_earned": 50
      }
    ]
  },
  "badges": [...]
}
```

#### Get Achievement Progress
```
GET /api/v1/achievements/progress
Authorization: Bearer {token}
```

#### Check for New Unlocks
```
POST /api/v1/achievements/check-unlock
Authorization: Bearer {token}
```

#### Get Community Leaderboard
```
GET /api/v1/leaderboard?limit=10
Authorization: Bearer {token}
```

#### Get User's Public Achievements
```
GET /api/v1/user/{user_id}/achievements
Authorization: Bearer {token}
```

### 5. Subscription & Payment Endpoints

#### Get All Plans
```
GET /api/v1/subscriptions/plans
```

**Response:**
```json
{
  "status": "success",
  "plans": [
    {
      "plan": "free",
      "name": "Free",
      "price": 0,
      "features": ["Basic lottery generation", "Community sharing", "Limited insights"]
    },
    {
      "plan": "premium",
      "name": "Premium",
      "price": 4.99,
      "features": ["Daily lucky numbers", "Full astrology insights", "No ads", "Advanced analytics"]
    },
    {
      "plan": "gold",
      "name": "Gold",
      "price": 9.99,
      "features": ["Premium features", "Astrologer consultations", "Lottery pools", "24/7 support"]
    },
    {
      "plan": "platinum",
      "name": "Platinum",
      "price": 19.99,
      "features": ["All features", "Priority support", "VIP events", "Exclusive astrologers"]
    }
  ]
}
```

#### Get Current Subscription
```
GET /api/v1/subscriptions/current
Authorization: Bearer {token}
```

#### Upgrade Subscription
```
POST /api/v1/subscriptions/upgrade
Authorization: Bearer {token}
Content-Type: application/json

{
  "plan": "premium"
}
```

#### Check Feature Availability
```
GET /api/v1/subscriptions/features/{feature}
Authorization: Bearer {token}
```

**Available Features:**
- `daily_lucky_numbers`
- `full_astrology_insights`
- `remove_ads`
- `advanced_analytics`
- `astrologer_consultations`
- `lottery_pools`
- `priority_support`
- `vip_events`
- `custom_reports`

#### Get Available Features for Plan
```
GET /api/v1/subscriptions/available-features
Authorization: Bearer {token}
```

#### Cancel Subscription
```
POST /api/v1/subscriptions/cancel
Authorization: Bearer {token}
Content-Type: application/json

{
  "reason": "Optional cancellation reason"
}
```

### 6. Lottery Pool Endpoints

#### Create Pool
```
POST /api/v1/pools/create
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Weekend Lottery Syndicate",
  "description": "Join us for the weekend draw",
  "lottery_type": "6/49",
  "numbers": "7,14,21,28,35,42",
  "entry_fee": 5.00,
  "max_members": 10
}
```

#### Join Pool
```
POST /api/v1/pools/{pool_id}/join
Authorization: Bearer {token}
```

#### Get Active Pools
```
GET /api/v1/pools?limit=10
Authorization: Bearer {token}
```

#### Get My Pools
```
GET /api/v1/pools/user/my-pools
Authorization: Bearer {token}
```

#### Get Pool Details
```
GET /api/v1/pools/{pool_id}
Authorization: Bearer {token}
```

#### Leave Pool
```
POST /api/v1/pools/{pool_id}/leave
Authorization: Bearer {token}
```

### 7. Challenge Endpoints

#### Create Challenge
```
POST /api/v1/challenges/create
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "January Jackpot Challenge",
  "description": "Win the most this January",
  "start_date": "2024-01-15T00:00:00Z",
  "end_date": "2024-01-31T23:59:59Z",
  "lottery_type": "Powerball",
  "max_participants": 100,
  "prize_pool": 1000.00,
  "difficulty": "medium"
}
```

#### Get Active Challenges
```
GET /api/v1/challenges?limit=10
Authorization: Bearer {token}
```

#### Join Challenge
```
POST /api/v1/challenges/{challenge_id}/join
Authorization: Bearer {token}
```

#### Get Challenge Leaderboard
```
GET /api/v1/challenges/{challenge_id}/leaderboard?limit=10
Authorization: Bearer {token}
```

#### Update Score
```
POST /api/v1/challenges/{challenge_id}/update-score
Authorization: Bearer {token}
Content-Type: application/json

{
  "score_increment": 10
}
```

#### End Challenge
```
POST /api/v1/challenges/{challenge_id}/end
Authorization: Bearer {token}
```

### 8. Astrologer Directory Endpoints

#### Register as Astrologer
```
POST /api/v1/astrologers/register
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Master Astrologer",
  "bio": "15+ years of experience in vedic astrology",
  "specialties": "Vedic Astrology, Numerology, Tarot",
  "hourly_rate": 50.00,
  "experience_years": 15,
  "certification": "International Astrology Association"
}
```

#### Get My Astrologer Profile
```
GET /api/v1/astrologers/profile
Authorization: Bearer {token}
```

#### Update Astrologer Profile
```
PUT /api/v1/astrologers/profile
Authorization: Bearer {token}
Content-Type: application/json

{
  "bio": "Updated bio",
  "hourly_rate": 55.00
}
```

#### Search Astrologers
```
GET /api/v1/astrologers/search?specialty=Vedic&min_rating=3.5&limit=10
Authorization: Bearer {token}
```

#### Get Astrologer Profile
```
GET /api/v1/astrologers/{astrologer_id}
Authorization: Bearer {token}
```

### 9. Consultation Booking Endpoints

#### Book Consultation
```
POST /api/v1/consultations/book
Authorization: Bearer {token}
Content-Type: application/json

{
  "astrologer_id": "astrologer-uuid",
  "topic": "Career and Life Path",
  "scheduled_time": "2024-01-20T15:00:00Z",
  "duration_minutes": 60
}
```

**Response:**
```json
{
  "status": "success",
  "session_id": "session-uuid",
  "message": "Consultation booked successfully",
  "cost": 50.00,
  "scheduled_time": "2024-01-20T15:00:00Z"
}
```

#### Get My Consultations
```
GET /api/v1/consultations?status=booked
Authorization: Bearer {token}
```

#### Get Consultation Details
```
GET /api/v1/consultations/{session_id}
Authorization: Bearer {token}
```

#### Start Consultation
```
POST /api/v1/consultations/{session_id}/start
Authorization: Bearer {token}
```

#### Complete Consultation
```
POST /api/v1/consultations/{session_id}/complete
Authorization: Bearer {token}
Content-Type: application/json

{
  "notes": "Optional notes from consultation"
}
```

#### Rate Consultation
```
POST /api/v1/consultations/{session_id}/rate
Authorization: Bearer {token}
Content-Type: application/json

{
  "rating": 5,
  "review": "Excellent consultation, very insightful"
}
```

#### Cancel Consultation
```
POST /api/v1/consultations/{session_id}/cancel
Authorization: Bearer {token}
```

### 10. Lottery Generation & History

#### Generate Lucky Numbers
```
POST /api/v1/generate-lucky-numbers
Authorization: Bearer {token}
Content-Type: application/json

{
  "lottery_type": "6/49"
}
```

**Response:**
```json
{
  "status": "success",
  "numbers": "7,14,21,28,35,42",
  "life_path": 7,
  "daily_lucky": 3,
  "lucky_color": "Blue",
  "energy_level": "High",
  "best_hours": "Morning"
}
```

#### Record Lottery Play
```
POST /api/v1/record-lottery
Authorization: Bearer {token}
Content-Type: application/json

{
  "lottery_type": "6/49",
  "numbers": "7,14,21,28,35,42"
}
```

#### Get Lottery History
```
GET /api/v1/lottery-history?limit=20
Authorization: Bearer {token}
```

### 11. Community Features

#### Create Lottery Share
```
POST /api/v1/community/shares
Authorization: Bearer {token}
Content-Type: application/json

{
  "numbers": "7,14,21,28,35,42",
  "lottery_type": "6/49",
  "description": "Lucky numbers based on today's astrology"
}
```

#### Get Public Shares
```
GET /api/v1/community/shares/public?limit=20
Authorization: Bearer {token}
```

#### Like Share
```
POST /api/v1/community/shares/{share_id}/like
Authorization: Bearer {token}
```

#### Get Community Leaderboard
```
GET /api/v1/community/leaderboard?limit=10
Authorization: Bearer {token}
```

## Database Models

### User
- `id`: UUID (Primary Key)
- `email`: String (Unique)
- `username`: String (Unique)
- `hashed_password`: String
- `full_name`: String
- `birth_date`: DateTime
- `birth_time`: String (HH:MM)
- `birth_place`: String
- `latitude`: Float
- `longitude`: Float
- `phone_number`: String
- `stripe_customer_id`: String
- `is_active`: Boolean
- `is_verified`: Boolean
- `created_at`: DateTime
- `updated_at`: DateTime

### Daily Insight
- `id`: UUID
- `user_id`: UUID (FK)
- `date`: Date
- `insight_text`: Text
- `recommendations`: JSON
- `lucky_hours`: String
- `warning`: Text
- `best_activities`: String
- `created_at`: DateTime

### User Badge
- `id`: UUID
- `user_id`: UUID (FK)
- `badge_name`: String
- `badge_icon`: String
- `description`: Text
- `points_earned`: Integer
- `unlocked_date`: DateTime

### Subscription
- `id`: UUID
- `user_id`: UUID (FK, Unique)
- `plan`: String (free, premium, gold, platinum)
- `status`: String
- `stripe_subscription_id`: String
- `amount`: Float
- `renews_at`: DateTime
- `created_at`: DateTime
- `updated_at`: DateTime

### Astrologer Profile
- `id`: UUID
- `user_id`: UUID (FK, Unique)
- `title`: String
- `bio`: Text
- `specialties`: String
- `hourly_rate`: Float
- `rating`: Float
- `reviews_count`: Integer
- `is_verified`: Boolean
- `experience_years`: Integer
- `certification`: String
- `availability`: JSON

### Consultation Session
- `id`: UUID
- `astrologer_id`: UUID (FK)
- `user_id`: UUID (FK)
- `topic`: String
- `status`: String (booked, active, completed, cancelled)
- `scheduled_time`: DateTime
- `duration_minutes`: Integer
- `cost`: Float
- `meeting_link`: String
- `notes`: Text
- `rating`: Integer (1-5)
- `review`: Text
- `created_at`: DateTime
- `updated_at`: DateTime

### Lottery Pool
- `id`: UUID
- `creator_id`: UUID (FK)
- `name`: String
- `description`: Text
- `lottery_type`: String
- `numbers`: String
- `entry_fee`: Float
- `max_members`: Integer
- `current_members`: Integer
- `status`: String
- `pool_draw_date`: DateTime
- `total_pool_amount`: Float
- `total_winnings`: Float
- `created_at`: DateTime

### Challenge
- `id`: UUID
- `creator_id`: UUID (FK)
- `title`: String
- `description`: Text
- `start_date`: DateTime
- `end_date`: DateTime
- `lottery_type`: String
- `max_participants`: Integer
- `prize_pool`: Float
- `difficulty`: String
- `created_at`: DateTime

## Badge System

### Available Badges

1. **First Draw** 🎰
   - Condition: Generate first lucky numbers
   - Points: 10

2. **Lucky Streak** ⭐
   - Condition: Play 10 lotteries
   - Points: 50

3. **Dedicated Player** 🏆
   - Condition: Play 50 lotteries
   - Points: 200

4. **Lottery Master** 👑
   - Condition: Play 100 lotteries
   - Points: 500

5. **First Winner** 🎊
   - Condition: Win first prize
   - Points: 100

6. **Fortune's Favorite** 💎
   - Condition: Win 5 times
   - Points: 250

7. **Community Spirit** 🤝
   - Condition: Share numbers
   - Points: 30

8. **Social Butterfly** 🦋
   - Condition: Follow 10 users
   - Points: 75

And more...

## Subscription Plans

### Free
- Basic lottery generation
- Community sharing
- Limited insights

### Premium ($4.99/month)
- Daily lucky numbers
- Full astrology insights
- No ads
- Advanced analytics

### Gold ($9.99/month)
- Premium features
- Astrologer consultations
- Lottery pools
- 24/7 support

### Platinum ($19.99/month)
- All features
- Priority support
- VIP events
- Exclusive astrologers

## Error Handling

All endpoints return errors in the following format:

```json
{
  "status": "error",
  "detail": "Error message here",
  "code": "ERROR_CODE"
}
```

Common HTTP Status Codes:
- `200`: Success
- `201`: Created
- `400`: Bad Request
- `401`: Unauthorized
- `403`: Forbidden
- `404`: Not Found
- `500`: Internal Server Error

## Rate Limiting

All endpoints are currently unlimited. Consider implementing rate limiting for production.

## WebSocket Support (Future)

Real-time features planned:
- Live challenge leaderboards
- Live event generation
- Real-time consultation notifications
- Instant badge unlocks

## File Structure

```
backend/
├── app/
│   ├── api/
│   │   ├── routes/
│   │   │   ├── __init__.py
│   │   │   ├── insights.py
│   │   │   ├── payments.py
│   │   │   ├── pools.py
│   │   │   └── astrologers.py
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── users.py
│   │   └── community.py
│   ├── core/
│   │   ├── config.py
│   │   └── security.py
│   ├── db/
│   ├── models/
│   │   └── models.py
│   ├── services/
│   │   ├── insights_service.py
│   │   ├── badge_service.py
│   │   ├── notification_service.py
│   │   ├── payment_service.py
│   │   ├── pool_service.py
│   │   ├── astrologer_service.py
│   │   ├── lottery_service.py
│   │   └── user_service.py
│   ├── utils/
│   ├── main.py
│   └── __init__.py
├── requirements.txt
└── run.py
```

## Development

### Setup
```bash
python -m pip install -r requirements.txt
python setup_db.py
python run.py
```

### API Documentation
Visit `http://localhost:8000/docs` for interactive Swagger documentation.

### Testing
```bash
pytest tests/
```

## Support

For issues and feature requests, please contact support@astroluck.com
