# AI Daily Insights - API Reference

## Base URL
```
https://api.astroluck.com/api/v1/insights
```

## Authentication
All endpoints require Bearer token authentication:
```
Authorization: Bearer <JWT_TOKEN>
```

## Response Format
All responses are JSON:
```json
{
  "success": true,
  "data": {...},
  "error": null
}
```

---

## Insights Retrieval

### Get Daily Insight
Get today's base insight for a zodiac sign.

**Endpoint:** `GET /daily`

**Query Parameters:**
- `zodiac_sign` (optional): Zodiac sign (aries, taurus, etc.). Uses user profile if not provided.

**Request:**
```bash
GET /daily?zodiac_sign=leo
```

**Response (200):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "date": "2024-01-15T00:05:00Z",
  "zodiac_sign": "leo",
  "title": "Leo's Cosmic Alignment: Embrace Your Inner Power",
  "short_summary": "Today brings powerful alignment for your personal projects.",
  "full_content": "The stars align in remarkable ways today...",
  "mood": "positive",
  "confidence_score": 0.95,
  "sections": {
    "lucky_times": {
      "start": "09:00",
      "end": "12:00",
      "secondary": "18:00-20:00"
    },
    "lucky_colors": ["gold", "ruby", "orange"],
    "lucky_numbers": [5, 12, 23],
    "element_focus": "fire",
    "power_affirmation": "I am a natural leader...",
    "tarot_card": "The Sun",
    "numerology": {
      "day_number": 5,
      "message": "Adventure and dynamic energy"
    },
    "career_focus": "Take initiative on delayed projects",
    "romance_insight": "Confidence attracts admirers",
    "health_tip": "Channel restless energy into exercise"
  },
  "astrological_data": {
    "moon_phase": "waxing_gibbous",
    "mercury_retrograde": false,
    "planetary_positions": {
      "sun": "capricorn",
      "moon": "gemini",
      "venus": "pisces"
    }
  },
  "view_count": 1234
}
```

**Error Responses:**
- `400`: Zodiac sign required (not in query or profile)
- `404`: Daily insight not available yet
- `401`: Unauthorized (invalid/missing token)

---

### Get Personalized Insight
Get today's personalized insight for current user.

**Endpoint:** `GET /daily/personalized`

**Request:**
```bash
GET /daily/personalized
```

**Response (200):**
```json
{
  "id": "660e8400-e29b-41d4-a716-446655440111",
  "base_insight_id": "550e8400-e29b-41d4-a716-446655440000",
  "personalized_title": "Sarah, Today's Cosmic Alignment Brings Opportunity",
  "personalized_content": "Hi Sarah! The universe has special guidance for you today...",
  "sections": {
    "lucky_times": {
      "start": "14:00",
      "end": "17:00",
      "note": "Perfect for your important meeting"
    },
    "lucky_colors": ["gold", "ruby"],
    "lucky_numbers": [5, 12, 23],
    "power_affirmation": "Sarah, I embrace the cosmic opportunity before me..."
  },
  "scheduled_delivery_time": "2024-01-15T09:00:00+00:00",
  "delivered_at": null,
  "view_count": 0,
  "user_history_context": "Based on your recent pattern: 5 insights viewed, avg rating 4.3⭐"
}
```

**Notes:**
- Auto-personalizes if not created yet
- Uses user's zodiac sign from profile
- Incorporates historical preferences

---

### Get Insight by Date
Get insight for specific date.

**Endpoint:** `GET /by-date`

**Query Parameters:**
- `date` (required): Date in YYYY-MM-DD format
- `zodiac_sign` (optional): Override user's zodiac

**Request:**
```bash
GET /by-date?date=2024-01-10&zodiac_sign=gemini
```

**Response (200):**
```json
{
  "id": "...",
  "date": "2024-01-10T00:05:00Z",
  "zodiac_sign": "gemini",
  "title": "Gemini's Quick Wit Shines Today",
  "full_content": "Mercury's position favors communication...",
  "sections": {...}
}
```

**Error Responses:**
- `400`: Invalid date format
- `404`: Insight not found for this date

---

### Get Insights by Zodiac
Get last N days of insights for zodiac sign.

**Endpoint:** `GET /by-zodiac/{zodiac_sign}`

**Path Parameters:**
- `zodiac_sign` (required): Zodiac sign

**Query Parameters:**
- `days` (optional, default 7): Number of days (1-30)

**Request:**
```bash
GET /by-zodiac/pisces?days=14
```

**Response (200):**
```json
{
  "zodiac_sign": "pisces",
  "count": 14,
  "insights": [
    {
      "id": "...",
      "date": "2024-01-15T00:05:00Z",
      "title": "Pisces in Dreamy Alignment",
      "mood": "positive",
      "short_summary": "Today brings creative flow...",
      "view_count": 342
    },
    {...},
    {...}
  ]
}
```

**Error Responses:**
- `400`: Invalid days parameter
- `404`: No insights found

---

### Get Trending Insights
Get most viewed/engaged insights.

**Endpoint:** `GET /trending`

**Query Parameters:**
- `limit` (optional, default 10, max 50): Number of results

**Request:**
```bash
GET /trending?limit=20
```

**Response (200):**
```json
{
  "count": 20,
  "trending": [
    {
      "id": "...",
      "title": "Leo Rules: Your Moment is Now",
      "zodiac_sign": "leo",
      "view_count": 5678,
      "engagement_score": 12340
    },
    {...}
  ]
}
```

---

### Search Insights
Full-text search by title or content.

**Endpoint:** `GET /search`

**Query Parameters:**
- `query` (required, min 2 chars): Search term
- `limit` (optional, default 20, max 100): Results

**Request:**
```bash
GET /search?query=luck&limit=50
```

**Response (200):**
```json
{
  "query": "luck",
  "count": 45,
  "results": [
    {
      "id": "...",
      "date": "2024-01-15T00:05:00Z",
      "zodiac_sign": "virgo",
      "title": "Luck Flows to the Prepared Mind",
      "short_summary": "Today brings fortunate encounters..."
    },
    {...}
  ]
}
```

---

## History & Favorites

### Get History
Get user's insight viewing history.

**Endpoint:** `GET /history`

**Query Parameters:**
- `limit` (optional, default 20, max 100): Results per page
- `offset` (optional, default 0): Pagination offset

**Request:**
```bash
GET /history?limit=50&offset=0
```

**Response (200):**
```json
{
  "count": 50,
  "history": [
    {
      "id": "...",
      "title": "Your Daily Cosmic Guidance",
      "zodiac_sign": "libra",
      "viewed_at": "2024-01-14T14:32:00Z",
      "time_spent_seconds": 245,
      "rating": 5,
      "is_favorite": true
    },
    {...}
  ]
}
```

---

### Get Favorites
Get saved/favorite insights.

**Endpoint:** `GET /favorites`

**Request:**
```bash
GET /favorites
```

**Response (200):**
```json
{
  "count": 12,
  "favorites": [
    {
      "id": "...",
      "title": "This Insight Changed My Day",
      "zodiac_sign": "capricorn",
      "rating": 5,
      "saved_at": "2024-01-10T09:15:00Z"
    },
    {...}
  ]
}
```

---

### Toggle Favorite
Add/remove insight from favorites.

**Endpoint:** `POST /history/{insight_id}/favorite`

**Path Parameters:**
- `insight_id` (required): UUID of insight

**Request:**
```bash
POST /history/550e8400-e29b-41d4-a716-446655440000/favorite
```

**Response (200):**
```json
{
  "success": true,
  "is_favorite": true
}
```

**Error Responses:**
- `404`: Insight not in history

---

## Engagement Tracking

### Log View
Log that user viewed an insight.

**Endpoint:** `POST /engagement/{insight_id}/view`

**Query Parameters:**
- `time_spent_seconds` (optional): How long spent reading

**Request:**
```bash
POST /engagement/550e8400-e29b-41d4-a716-446655440000/view?time_spent_seconds=180
```

**Response (200):**
```json
{
  "success": true,
  "message": "View logged"
}
```

---

### Log Share
Log share action.

**Endpoint:** `POST /engagement/{insight_id}/share`

**Query Parameters:**
- `platform` (required): "whatsapp" or "social"

**Request:**
```bash
POST /engagement/550e8400.../share?platform=whatsapp
```

**Response (200):**
```json
{
  "success": true,
  "message": "Shared to whatsapp"
}
```

**Error:** `400` if invalid platform

---

### Save Insight
Save insight temporarily.

**Endpoint:** `POST /engagement/{insight_id}/save`

**Request:**
```bash
POST /engagement/550e8400.../save
```

**Response (200):**
```json
{
  "success": true,
  "message": "Insight saved"
}
```

---

### Get Engagement Stats
Get user's overall engagement statistics.

**Endpoint:** `GET /engagement/stats`

**Request:**
```bash
GET /engagement/stats
```

**Response (200):**
```json
{
  "success": true,
  "total_views": 156,
  "saved_count": 23,
  "shared_count": 34,
  "engagement_rate": "36.5%"
}
```

---

## Preferences

### Get Preferences
Get user's current insight preferences.

**Endpoint:** `GET /preferences`

**Request:**
```bash
GET /preferences
```

**Response (200):**
```json
{
  "id": "user-pref-123",
  "insights_enabled": true,
  "delivery_time": "08:00",
  "delivery_timezone": "America/New_York",
  "delivery_frequency": "daily",
  "channels": {
    "email": true,
    "push": true,
    "whatsapp": false
  },
  "content_preferences": {
    "insight_types": ["general", "career", "romance"],
    "mood": "positive",
    "personalization_level": 0.95,
    "include_birth_chart": true,
    "include_transit_data": true,
    "include_numerology": false,
    "include_tarot": true
  },
  "writing_style": "inspiring",
  "content_length": "medium",
  "quiet_hours": {
    "enabled": true,
    "start": "22:00",
    "end": "08:00"
  },
  "auto_save_favorites": true,
  "enable_weekly_digest": true
}
```

---

### Update Preferences
Update multiple preferences at once.

**Endpoint:** `PUT /preferences`

**Request Body:**
```json
{
  "delivery_time": "07:30",
  "delivery_timezone": "UTC",
  "channels": {
    "email": false,
    "push": true,
    "whatsapp": true
  },
  "content_preferences": {
    "insight_types": ["general", "finance", "health"],
    "mood": "mixed"
  },
  "quietHours": {
    "enabled": false
  }
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Preferences updated"
}
```

---

### Reset Preferences
Reset all preferences to defaults.

**Endpoint:** `POST /preferences/reset`

**Request:**
```bash
POST /preferences/reset
```

**Response (200):**
```json
{
  "success": true,
  "message": "Preferences reset to defaults"
}
```

---

## Feedback & Ratings

### Submit Feedback
Submit rating and feedback on an insight.

**Endpoint:** `POST /feedback/{insight_id}`

**Query Parameters:**
- `rating` (required): 1-5 star rating
- `comment` (optional): User comment
- `tags` (optional): Comma-separated feedback tags

**Request:**
```bash
POST /feedback/550e8400...?rating=5&comment=This%20was%20amazing&tags=accurate,helpful,inspiring
```

**Response (200):**
```json
{
  "success": true,
  "message": "Feedback recorded"
}
```

**Error Responses:**
- `400`: Rating must be 1-5
- `400`: Invalid feedback parameters

---

### Get Feedback Summary
Get aggregated feedback for an insight.

**Endpoint:** `GET /feedback/{insight_id}/summary`

**Request:**
```bash
GET /feedback/550e8400.../summary
```

**Response (200):**
```json
{
  "success": true,
  "total_feedback": 234,
  "average_rating": "4.7",
  "positive_sentiment": "87%"
}
```

---

### Get My Feedback
Get all feedback submitted by current user.

**Endpoint:** `GET /feedback/my-feedback`

**Query Parameters:**
- `limit` (optional, default 20, max 100)
- `offset` (optional, default 0)

**Request:**
```bash
GET /feedback/my-feedback?limit=50
```

**Response (200):**
```json
{
  "count": 50,
  "feedback": [
    {
      "id": "...",
      "insight_id": "550e8400...",
      "rating": 5,
      "comment": "Absolutely accurate!",
      "tags": ["accurate", "helpful"],
      "created_at": "2024-01-14T14:32:00Z"
    },
    {...}
  ]
}
```

---

## Admin Endpoints

### Trigger Batch Generation
Manually generate daily insights for all zodiacs.

**Endpoint:** `POST /generate/batch`

**Note:** Admin role required

**Request:**
```bash
POST /generate/batch
```

**Response (200):**
```json
{
  "success": true,
  "insights_generated": 12,
  "generation_time_seconds": 45.3
}
```

---

### Get Generation Logs
View generation process logs.

**Endpoint:** `GET /generation-logs`

**Query Parameters:**
- `limit` (optional, default 50, max 200)
- `offset` (optional, default 0)

**Request:**
```bash
GET /generation-logs?limit=100
```

**Response (200):**
```json
{
  "count": 100,
  "logs": [
    {
      "id": "...",
      "generation_date": "2024-01-15T00:05:00Z",
      "ai_model": "gpt-4-turbo",
      "generation_time_seconds": 3.2,
      "confidence_score": 0.94,
      "status": "success",
      "total_generated": 12
    },
    {...}
  ]
}
```

---

### Get Quality Metrics
Get quality metrics for generated insights.

**Endpoint:** `GET /quality-metrics`

**Query Parameters:**
- `days` (optional, default 7, max 90): Period to analyze

**Request:**
```bash
GET /quality-metrics?days=30
```

**Response (200):**
```json
{
  "period_days": 30,
  "total_generations": 375,
  "successful": 368,
  "failed": 7,
  "success_rate": "98.1%",
  "average_confidence_score": "0.92",
  "average_diversity_score": "0.87",
  "average_generation_time_seconds": 2.4
}
```

---

## Personalization

### Trigger Personalization
Manually personalize insights for user.

**Endpoint:** `POST /personalize`

**Request:**
```bash
POST /personalize
```

**Response (200):**
```json
{
  "success": true,
  "personalized_insight_id": "660e8400-e29b-41d4-a716-446655440111",
  "user_id": "user-123"
}
```

---

### Send Notifications
Manually trigger notification sending.

**Endpoint:** `POST /send-notifications`

**Note:** Admin role required

**Request:**
```bash
POST /send-notifications
```

**Response (200):**
```json
{
  "success": true,
  "sent": 1234,
  "failed": 8
}
```

---

## Error Codes

| Code | Meaning | 
|------|---------|
| 200 | Success |
| 400 | Bad request (validation error) |
| 401 | Unauthorized (invalid token) |
| 403 | Forbidden (insufficient permissions) |
| 404 | Not found |
| 429 | Rate limited |
| 500 | Server error |
| 503 | Service unavailable |

---

## Rate Limiting

- **Limit:** 1000 requests/hour per user
- **Header:** `X-RateLimit-Remaining`
- **Reset:** `X-RateLimit-Reset` (Unix timestamp)

---

## Versioning

Current: `v1`
- Breaking changes: New major version
- Non-breaking: Documented in CHANGELOG.md

---

## Examples

### Complete Flow: View & Rate Insight

```bash
# 1. Get personalized insight
GET /daily/personalized

# 2. Log the view
POST /engagement/{insight_id}/view?time_spent_seconds=300

# 3. Share to WhatsApp
POST /engagement/{insight_id}/share?platform=whatsapp

# 4. Submit rating
POST /feedback/{insight_id}?rating=5&comment=Amazing
```

### Save Preferences Workflow

```bash
# 1. Get current preferences
GET /preferences

# 2. Update delivery settings
PUT /preferences
{
  "delivery_time": "09:00",
  "delivery_timezone": "America/Los_Angeles"
}

# 3. Verify update
GET /preferences
```

---

## Support

For issues, contact: `api-support@astroluck.com`
Status page: `https://status.astroluck.com/`
