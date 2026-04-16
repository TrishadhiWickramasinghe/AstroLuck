# 🔌 Intelligence & Analytics API - Complete Reference

## Base URL
```
http://localhost:8000/api/v1/intelligence
```

## Authentication
All endpoints require Bearer token in `Authorization` header:
```
Authorization: Bearer <jwt_token>
```

---

## 📋 Endpoint Reference

### 1. GET /numerology/{user_id}

Get user's complete numerology profile.

**URL Parameters**:
- `user_id` (integer, required): User ID

**Request**:
```bash
curl -X GET "http://localhost:8000/api/v1/intelligence/numerology/1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response (200 OK)**:
```json
{
  "user_id": 1,
  "life_path_number": 7,
  "destiny_number": 3,
  "soul_urge_number": 9,
  "personality_number": 4,
  "expression_number": 3,
  "birth_force_number": 5,
  "created_at": "2024-01-15T10:30:00",
  "updated_at": "2024-01-15T10:30:00"
}
```

**Error Responses**:
- `401 Unauthorized`: Invalid or missing token
- `404 Not Found`: User not found
- `400 Bad Request`: Missing birth date or name

---

### 2. GET /numerology/details/{user_id}

Get numerology profile with detailed interpretations.

**URL Parameters**:
- `user_id` (integer, required): User ID

**Request**:
```bash
curl -X GET "http://localhost:8000/api/v1/intelligence/numerology/details/1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response (200 OK)**:
```json
{
  "user_id": 1,
  "life_path": {
    "number": 7,
    "meaning": "The Seeker - Spiritual journey and inner wisdom",
    "strengths": ["Intuitive", "Analytical", "Spiritual"],
    "challenges": ["Over-analytical", "Withdrawn"],
    "career_paths": ["Counselor", "Teacher", "Researcher"]
  },
  "destiny": {
    "number": 3,
    "meaning": "Creative self-expression and communication",
    "strengths": ["Creative", "Expressive", "Social"],
    "challenges": ["Scattered", "Indecisive"],
    "career_paths": ["Artist", "Writer", "Speaker"]
  },
  "soul_urge": {
    "number": 9,
    "meaning": "Humanitarian service and universal love",
    "core_desire": "To serve humanity with compassion"
  },
  "personality": {
    "number": 4,
    "meaning": "Practical and reliable - appears grounded",
    "outward_traits": ["Organized", "Dependable", "Practical"]
  },
  "expression": {
    "number": 3,
    "meaning": "Talented communicator with creative gifts",
    "natural_talents": ["Communication", "Creativity", "Expression"]
  },
  "personal_description": "You are a spiritual seeker with humanitarian goals...",
  "compatibility": {
    "best_matches": [1, 7, 9],
    "moderate_matches": [2, 5, 6],
    "challenging_matches": [4, 8]
  },
  "lucky_numbers": [7, 9, 16, 25, 34],
  "lucky_days": ["Wednesday", "Thursday"],
  "lucky_colors": ["Purple", "Indigo"],
  "suggested_careers": ["Counselor", "Teacher", "Researcher"],
  "life_lesson": "Trust your inner wisdom and share it with others",
  "created_at": "2024-01-15T10:30:00"
}
```

---

### 3. GET /probability/{user_id}

Get win probability predictions for all lottery types.

**URL Parameters**:
- `user_id` (integer, required): User ID

**Query Parameters**:
- `lottery_type` (string, optional): Filter by specific lottery type (astro, daily, weekly)

**Request**:
```bash
curl -X GET "http://localhost:8000/api/v1/intelligence/probability/1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Or specific lottery
curl -X GET "http://localhost:8000/api/v1/intelligence/probability/1?lottery_type=astro" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response (200 OK)**:
```json
{
  "user_id": 1,
  "probabilities": {
    "astro_lottery": {
      "probability": 0.32,
      "confidence": 0.78,
      "hot_numbers": [7, 14, 21, 28],
      "cold_numbers": [2, 5, 11, 13],
      "predicted_next": [7, 14, 21, 28, 35, 42],
      "last_winning_numbers": [7, 21, 28, 35, 42, 49],
      "pattern_frequency": 0.87,
      "recommendation": "play"
    },
    "daily_lottery": {
      "probability": 0.25,
      "confidence": 0.65,
      "hot_numbers": [3, 6, 9, 12],
      "recommendation": "wait"
    },
    "weekly_lottery": {
      "probability": 0.45,
      "confidence": 0.82,
      "hot_numbers": [1, 4, 7, 10],
      "recommendation": "play"
    }
  },
  "overall_recommendation": "play",
  "best_lottery": "weekly_lottery",
  "created_at": "2024-01-15T10:30:00"
}
```

**Probability Interpretation**:
- `0.0 - 0.2`: Very Low probability
- `0.2 - 0.4`: Low probability
- `0.4 - 0.6`: Medium probability
- `0.6 - 0.8`: High probability
- `0.8 - 1.0`: Very High probability

---

### 4. GET /statistics/{user_id}

Get user's lottery statistics and performance metrics.

**URL Parameters**:
- `user_id` (integer, required): User ID

**Request**:
```bash
curl -X GET "http://localhost:8000/api/v1/intelligence/statistics/1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response (200 OK)**:
```json
{
  "user_id": 1,
  "total_plays": 150,
  "total_wins": 18,
  "win_rate": 0.12,
  "win_rate_percentage": "12%",
  "current_streak": 2,
  "longest_streak": 7,
  "average_streak": 1.5,
  "avg_numbers_per_play": 6,
  "most_played_number": 7,
  "least_played_number": 2,
  "performance_vs_average": 0.85,
  "trend": "improving",
  "last_updated": "2024-01-15T10:30:00"
}
```

---

### 5. GET /hot-cold/{user_id}

Get detailed hot/cold numbers analysis.

**URL Parameters**:
- `user_id` (integer, required): User ID

**Request**:
```bash
curl -X GET "http://localhost:8000/api/v1/intelligence/hot-cold/1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response (200 OK)**:
```json
{
  "user_id": 1,
  "hot_numbers": {
    "very_hot": [7, 14, 21, 28, 35],
    "hot": [6, 13, 22, 29, 36],
    "average": [1, 2, 3, 4, 5],
    "cold": [8, 9, 10, 11, 12],
    "very_cold": [42, 43, 44, 45, 46, 47, 48, 49]
  },
  "frequency_distribution": {
    "average_frequency": 2.8,
    "highest_frequency": 12,
    "lowest_frequency": 0,
    "min_number": 1,
    "max_number": 49
  },
  "number_frequency": [
    { "number": 7, "frequency": 12, "percentile": 95 },
    { "number": 14, "frequency": 10, "percentile": 90 },
    { "number": 21, "frequency": 9, "percentile": 85 },
    { "number": 2, "frequency": 0, "percentile": 5 }
  ],
  "analysis": "Hot numbers are 7, 14, 21 - consider playing these",
  "last_analyzed": "2024-01-15T10:30:00"
}
```

---

### 6. GET /patterns/{user_id}

Get pattern analysis and trend predictions.

**URL Parameters**:
- `user_id` (integer, required): User ID

**Request**:
```bash
curl -X GET "http://localhost:8000/api/v1/intelligence/patterns/1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response (200 OK)**:
```json
{
  "user_id": 1,
  "patterns": {
    "number_sequences": [
      [7, 14, 21],
      [3, 6, 9],
      [4, 8, 12]
    ],
    "repeating_pairs": [
      [7, 14, 5],
      [21, 28, 3]
    ],
    "gap_patterns": [
      { "pattern": [7, 21], "gap": 14, "frequency": 3 },
      { "pattern": [3, 9], "gap": 6, "frequency": 2 }
    ]
  },
  "trends": {
    "increasing_numbers": [7, 14],
    "decreasing_numbers": [2, 5],
    "stable_numbers": [21, 28]
  },
  "markov_chain_predictions": [7, 14, 21, 28, 35, 42],
  "pattern_confidence": 0.76,
  "cycle_analysis": {
    "weekly_cycle": "Numbers repeat every 7-14 draws",
    "monthly_cycle": "Stronger patterns in first week of month"
  },
  "next_predicted_draw": [7, 14, 21, 28, 35, 42],
  "last_analyzed": "2024-01-15T10:30:00"
}
```

---

### 7. GET /ai-insights/{user_id}

Get daily AI insights for user.

**URL Parameters**:
- `user_id` (integer, required): User ID

**Query Parameters**:
- `limit` (integer, optional): Number of insights (default: 1)
- `days` (integer, optional): Days to look back (default: 1)

**Request**:
```bash
curl -X GET "http://localhost:8000/api/v1/intelligence/ai-insights/1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response (200 OK)**:
```json
[
  {
    "id": 1,
    "user_id": 1,
    "title": "Abundant Energy Day",
    "description": "Today brings exceptional opportunities. Jupiter's influence is strong.",
    "horoscope": "Full horoscope for today based on your birth chart...",
    "mood": "Energetic",
    "energy_level": 8,
    "lottery_recommendation": "play",
    "recommended_numbers": [7, 14, 21, 28, 35, 42],
    "avoid_numbers": [3, 13, 19],
    "best_time_of_day": "3-5 PM",
    "ruling_planet": "Jupiter",
    "planetary_influence": "Strong expansion and abundance energy today",
    "health_advice": "Stay hydrated and take regular breaks",
    "meditation_recommendation": "10-minute abundance meditation",
    "breathing_exercise": "4-7-8 breathing technique: inhale 4, hold 7, exhale 8",
    "spending_forecast": "conservative",
    "financial_advice": "Save rather than spend today",
    "lucky_color_of_day": "#FFD700",
    "lucky_gemstone": "Citrine",
    "lucky_scent": "Orange Blossom",
    "daily_affirmation": "I attract abundance with gratitude",
    "confidence_score": 0.88,
    "created_at": "2024-01-15T10:30:00"
  }
]
```

---

### 8. POST /ai-insights/{user_id}/regenerate

Regenerate AI insights (force new generation).

**URL Parameters**:
- `user_id` (integer, required): User ID

**Request**:
```bash
curl -X POST "http://localhost:8000/api/v1/intelligence/ai-insights/1/regenerate" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json"
```

**Response (200 OK)**:
Returns same format as GET /ai-insights/{user_id}

**Error Responses**:
- `429 Too Many Requests`: Regeneration cooldown (can regenerate once per day)
- `401 Unauthorized`: Invalid token

---

### 9. GET /dashboard/{user_id}

Get complete analytics dashboard with all intelligence data.

**URL Parameters**:
- `user_id` (integer, required): User ID

**Request**:
```bash
curl -X GET "http://localhost:8000/api/v1/intelligence/dashboard/1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response (200 OK)**:
```json
{
  "user_id": 1,
  "dashboard": {
    "numerology": {
      "life_path": 7,
      "destiny": 3,
      "soul_urge": 9,
      "personality": 4,
      "expression": 3
    },
    "probabilities": {
      "astro_lottery": 0.32,
      "daily_lottery": 0.25,
      "weekly_lottery": 0.45
    },
    "statistics": {
      "total_plays": 150,
      "total_wins": 18,
      "win_rate": 0.12
    },
    "hot_cold": {
      "very_hot": [7, 14, 21, 28, 35],
      "very_cold": [42, 43, 44, 45, 46, 47, 48, 49]
    },
    "today_insight": {
      "title": "Abundant Energy Day",
      "recommendation": "play",
      "lucky_numbers": [7, 14, 21],
      "best_time": "3-5 PM"
    }
  },
  "last_updated": "2024-01-15T10:30:00"
}
```

---

### 10. GET /predictions/{user_id}

Get all predictions for the next 30 days.

**URL Parameters**:
- `user_id` (integer, required): User ID

**Query Parameters**:
- `days` (integer, optional): Number of days to predict (default: 30, max: 90)
- `lottery_type` (string, optional): Filter by lottery type

**Request**:
```bash
curl -X GET "http://localhost:8000/api/v1/intelligence/predictions/1?days=30" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response (200 OK)**:
```json
{
  "user_id": 1,
  "predictions": [
    {
      "date": "2024-01-16",
      "day_of_week": "Tuesday",
      "overall_energy": 7,
      "best_lottery": "weekly_lottery",
      "predicted_numbers": [7, 14, 21, 28, 35, 42],
      "recommendation": "play"
    },
    {
      "date": "2024-01-17",
      "day_of_week": "Wednesday",
      "overall_energy": 6,
      "best_lottery": "astro_lottery",
      "predicted_numbers": [3, 6, 9, 12, 15, 18],
      "recommendation": "wait"
    }
  ],
  "summary": {
    "best_days": ["2024-01-16", "2024-01-21", "2024-01-25"],
    "play_days": 12,
    "wait_days": 10,
    "caution_days": 8
  },
  "generated_at": "2024-01-15T10:30:00"
}
```

---

## 🔒 Error Responses

All endpoints can return these error responses:

### 400 Bad Request
```json
{
  "detail": "Invalid user_id format"
}
```

### 401 Unauthorized
```json
{
  "detail": "Not authenticated"
}
```

### 403 Forbidden
```json
{
  "detail": "Not enough permissions"
}
```

### 404 Not Found
```json
{
  "detail": "User not found"
}
```

### 429 Too Many Requests
```json
{
  "detail": "Rate limit exceeded. Try again in 60 seconds"
}
```

### 500 Internal Server Error
```json
{
  "detail": "Internal server error"
}
```

---

## 📊 Response Headers

All successful responses include:
```
X-Total-Count: 150
X-Page: 1
X-Page-Size: 50
X-Generated-Time: 0.234s
```

---

## 🧪 Testing Endpoints

### cURL Examples

**Get Numerology Profile**:
```bash
curl -X GET "http://localhost:8000/api/v1/intelligence/numerology/1" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."
```

**Get Today's AI Insights**:
```bash
curl -X GET "http://localhost:8000/api/v1/intelligence/ai-insights/1" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."
```

**Get Probability Predictions**:
```bash
curl -X GET "http://localhost:8000/api/v1/intelligence/probability/1" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."
```

**Get Complete Dashboard**:
```bash
curl -X GET "http://localhost:8000/api/v1/intelligence/dashboard/1" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."
```

---

## 📱 Flutter Integration

### Basic Usage
```dart
// Get numerology profile
final numerology = await apiClient.get(
  '/api/v1/intelligence/numerology/1'
);

// Get today's insight
final insight = await apiClient.get(
  '/api/v1/intelligence/ai-insights/1'
);

// Get probability predictions
final probability = await apiClient.get(
  '/api/v1/intelligence/probability/1'
);
```

### With Riverpod
```dart
final numerologyProvider = FutureProvider.family(
  (ref, userId) => ApiClient().get(
    '/api/v1/intelligence/numerology/$userId'
  ),
);
```

---

## 🚀 Performance Notes

- All endpoints cached for 30 minutes
- Regenerate cache: POST /cache/clear/{user_id}
- Typical response time: 50-300ms
- Maximum payload size: 1MB
- Rate limit: 100 requests per user per hour

---

## 🔄 Changelog

### v1.0.0 (Current)
- Initial release with 10 endpoints
- Numerology calculations
- Probability modeling
- AI insights generation
- Statistical analysis

### Future Versions
- v1.1.0: Export features (PDF reports)
- v1.2.0: Social sharing features
- v1.3.0: Advanced ML predictions
- v2.0.0: Real-time collaboration
