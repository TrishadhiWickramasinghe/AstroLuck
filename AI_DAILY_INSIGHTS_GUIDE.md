# AI Daily Insights - Implementation Guide

## Overview

AI Daily Insights is a personalized astrological intelligence system that generates daily cosmic guidance tailored to each user. It combines AI-powered content generation, astrological calculations, and user personalization to deliver highly engaging, retention-focused insights.

**Key Metrics:**
- Expected Engagement Increase: +50%
- Expected Retention Increase: +25%
- Daily Active Users Impact: Significant boost through personalization

## Architecture

### Backend Stack

**Technology:**
- Framework: FastAPI (Python)
- Database: PostgreSQL with SQLAlchemy ORM
- AI Model: GPT-4 or Claude-3 for content generation
- Task Queue: Celery with Redis (for background job scheduling)
- External APIs: OpenAI, Astronomy libraries (PyEphem or Astropy)

### Database Schema (7 Models)

#### 1. DailyInsight
Base insight generated for all zodiac signs daily.

**Fields:**
- `id`: UUID primary key
- `date`: DateTime (when insight was generated)
- `zodiac_sign`: Zodiac sign (aries, taurus, etc.)
- `title`: Compelling insight title
- `short_summary`: 1-2 sentence summary
- `full_content`: Complete insight (2-3 paragraphs)
- `insight_type`: Enum (GENERAL, LUCKY_TIMES, ROMANCE, CAREER, etc.)
- `mood`: Enum (POSITIVE, NEUTRAL, CAUTIOUS, TRANSFORMATIVE)
- `confidence_score`: Float (0-1) for quality metric
- `moon_phase`: Current lunar phase
- `current_planetary_positions`: JSON object with planet positions
- `mercury_retrograde`: Boolean flag
- `sections`: JSON with structured data (lucky times, colors, numbers, tarot, etc.)
- `ai_model_version`: GPT-4-turbo, claude-3, etc.
- `generation_method`: Enum (ALGORITHMIC, LLM, HYBRID)
- `status`: Enum (GENERATED, PERSONALIZED, SCHEDULED, DELIVERED, FAILED)
- `view_count`: Total views across all users
- `interaction_count`: Shares, saves, clicks combined
- `save_count`: Number of times saved to favorites
- `published_at`: When insight went live
- **Relationships:**
  - User (many insights per user via personalization)
  - InsightEngagementLog (one-to-many)
  - InsightFeedback (one-to-many)

#### 2. DailyInsightPersonalized
User-specific personalized version of base insight.

**Fields:**
- `id`: UUID primary key
- `base_insight_id`: Foreign key to DailyInsight
- `user_id`: Foreign key to User
- `personalized_title`: User-customized title (includes name if available)
- `personalized_content`: User-customized content
- `personalization_factors`: JSON object tracking what factors were used
  - `used_birth_time`: Boolean if birth time was factored in
  - `transit_date`: Date of transit data considered
  - `preferences`: List of user preferences incorporated
  - `personalization_level`: 0-1 score indicating depth
- `personalized_sections`: JSON with user-customized sections
- `user_history_context`: Summary of user's past insight patterns
- `scheduled_delivery_time`: When to send to user
- `delivery_timezone`: User's timezone for scheduling
- `delivered_at`: When insight was actually delivered
- `view_count`: User's view count of this personalized version
- `engagement_count`: User's total interactions
- `time_spent_seconds`: Total time user spent reading
- `created_at`: Personalization creation timestamp
- **Relationships:**
  - DailyInsight (many-to-one)
  - User (many-to-one)
  - InsightEngagementLog (one-to-many)
  - InsightFeedback (one-to-many)

#### 3. InsightEngagementLog
Complete engagement tracking for each user-insight interaction.

**Fields:**
- `id`: UUID primary key
- `user_id`: Foreign key
- `insight_id`: Foreign key to DailyInsight
- `personalized_insight_id`: Optional FK to personalized version
- `view_count`: Number of times viewed
- `opened_at`: First time opened
- `time_spent_seconds`: Total reading time
- `clicked_to_details`: Boolean if clicked "Read more"
- `clicked_lucky_times`: Boolean if clicked lucky times section
- `clicked_lucky_numbers`: Boolean if clicked numbers section
- `shared_to_whatsapp`: Boolean
- `shared_to_social`: Boolean
- `is_saved`: Boolean if saved to collection
- `saved_at`: Timestamp when saved
- `is_bookmarked`: Boolean if bookmarked
- `bookmarked_at`: Timestamp
- `notification_sent`: Boolean if push sent
- `opened_from_notification`: Boolean
- `entry_point`: Enum (HOME, SETTINGS, NOTIFICATION, SEARCH)
- `source_platform`: Enum (DAILY_FEED, NOTIFICATION, SEARCH, etc.)
- `created_at`: First engagement timestamp
- `updated_at`: Last engagement timestamp

#### 4. UserInsightPreference
Comprehensive user preferences (one per user).

**Fields:**
- `id`: UUID primary key
- `user_id`: Foreign key, unique constraint
- `insights_enabled`: Boolean (default True)
- `delivery_time`: Time string (HH:MM format)
- `delivery_timezone`: User's timezone string
- `delivery_frequency`: Enum (DAILY, WEEKLY, CUSTOM)
- `send_via_email`: Boolean
- `send_via_push`: Boolean
- `send_via_whatsapp`: Boolean
- `preferred_insight_types`: JSON array of insight type preferences
- `preferred_mood`: Enum (POSITIVE, MIXED, CAUTIOUS)
- `personalization_level`: Float (0.5-1.0) - how personalized
- `include_birth_chart_insights`: Boolean
- `include_transit_data`: Boolean
- `include_numerology`: Boolean
- `include_tarot`: Boolean
- `writing_style`: Enum (INSPIRING, SCIENTIFIC, MYSTICAL)
- `content_length`: Enum (SHORT, MEDIUM, LONG)
- `quiet_hours_enabled`: Boolean
- `quiet_hours_start`: Time string
- `quiet_hours_end`: Time string
- `auto_save_favorites`: Boolean
- `enable_weekly_digest`: Boolean
- `created_at`: Timestamp
- `updated_at`: Timestamp
- **Relationships:**
  - User (one-to-one)

#### 5. InsightHistory
User's complete viewing history.

**Fields:**
- `id`: UUID primary key
- `user_id`: Foreign key
- `insight_id`: Foreign key to base insight
- `personalized_insight_id`: Optional FK to personalized version
- `title`: Insight title (denormalized for quick access)
- `zodiac_sign`: Zodiac (denormalized)
- `insight_type`: Type (denormalized)
- `viewed`: Boolean
- `viewed_at`: Timestamp of first view
- `time_spent_seconds`: Total time spent
- `interaction_count`: How many interactions
- `is_favorite`: Boolean (saved to favorites)
- `rating`: Int 1-5 if rated
- `shared_count`: How many times shared
- `is_archived`: Boolean
- `archived_at`: Timestamp
- `created_at`: Entry creation
- `updated_at`: Last update
- **Relationships:**
  - User (many-to-one)
  - DailyInsight (many-to-one)
  - DailyInsightPersonalized (many-to-one, optional)

#### 6. InsightFeedback
User feedback for ML training and quality improvement.

**Fields:**
- `id`: UUID primary key
- `user_id`: Foreign key
- `insight_id`: Foreign key
- `overall_rating`: Int 1-5
- `accuracy_rating`: Int 1-5 (how accurate was it?)
- `relevance_rating`: Int 1-5 (how relevant?)
- `comment`: Text (optional user comment)
- `feedback_tags`: JSON array of tags (too_generic, helpful, accurate, inaccurate, inspiring, skeptical, validated)
- `was_accurate`: Boolean
- `was_helpful`: Boolean
- `would_recommend`: Boolean
- `sentiment`: Enum (POSITIVE, NEUTRAL, NEGATIVE)
- `emotion_classification`: Enum (INSPIRED, SKEPTICAL, VALIDATED, NEUTRAL)
- `helpful_for_training`: Boolean flag for ML
- `created_at`: Timestamp
- **Relationships:**
  - User (many-to-one)
  - DailyInsight (many-to-one)
  - DailyInsightPersonalized (many-to-one, optional)

#### 7. InsightGenerationLog
Process monitoring and quality assurance logging.

**Fields:**
- `id`: UUID primary key
- `generation_date`: Date generated
- `zodiac_sign`: Optional (if single zodiac generated)
- `ai_model_used`: String (gpt-4, claude-3, etc.)
- `generation_method`: Enum (LLM, ALGORITHMIC, HYBRID)
- `generation_time_seconds`: Float
- `cost_estimate`: Float (API costs)
- `tokens_used`: Int
- `status`: Enum (SUCCESS, FAILED, PARTIAL)
- `error_message`: Optional error text
- `confidence_score`: Float (0-1)
- `diversity_score`: Float (0-1) - how unique from past
- `personalization_score`: Float (0-1) - how well personalized
- `astrological_factors_used`: JSON list of factors
- `total_generated`: Int (how many insights in batch)
- `total_personalized`: Int (how many personalized)
- `total_delivered`: Int (how many successfully sent)
- `total_failed`: Int (delivery failures)
- `created_at`: Timestamp

### Service Layer (5 Services)

#### AIInsightGeneratorService
Generates daily insights for all zodiac signs using AI.

**Key Methods:**
- `generate_daily_insights_batch()`: Generate for all 12 zodiacs
- `_get_astrological_data()`: Fetch current planetary positions
- `_calculate_moon_phase(date)`: Calculate lunar cycle
- `_get_planetary_positions()`: Get planet positions by sign
- `_generate_zodiac_insight(zodiac, astrological_data)`: AI generation
- `_build_generation_prompt(zodiac, astrological_data)`: Craft LLM prompt
- `_log_generation(zodiac_signs, time, count)`: Log metrics

**Process Flow:**
1. Called daily at 00:05 UTC
2. For each zodiac sign:
   - Fetch astrological data
   - Build AI prompt with context
   - Call GPT-4 with structured output
   - Save DailyInsight record
3. Log generation metrics for monitoring

#### AIInsightPersonalizationService
Personalizes base insights for individual users.

**Key Methods:**
- `personalize_insights_for_user(user_id)`: Main personalization
- `_create_personalized_version(user, base_insight)`: Create personalized record
- `_personalize_sections(sections, user)`: Customize components
- `_get_user_history_summary(user_id)`: Build history context
- `_calculate_delivery_time(preferences)`: Schedule delivery

**Personalization Factors:**
- User's name (for personal touch)
- Birth chart data (if available)
- Transit information for their location
- Past insight preferences and ratings
- Most engaged content types
- Writing style preference
- Time zone for scheduling

#### AIInsightNotificationService
Sends personalized insights via multiple channels.

**Key Methods:**
- `send_personalized_insights()`: Main scheduler
- `_is_delivery_time(user_pref)`: Check if time to send
- `_send_insight_notifications(user, prefs, insight)`: Route to channels
- `_send_email_notification(user, insight)`: Email integration
- `_send_whatsapp_notification(user, insight)`: WhatsApp integration
- `_send_push_notification(user, insight)`: Push notification

**Features:**
- Timezone-aware delivery scheduling
- Multi-channel support (email, push, WhatsApp)
- Respects quiet hours
- Tracks delivery status
- Retry logic for failed sends

#### AIInsightEngagementService
Comprehensive engagement tracking and analytics.

**Key Methods:**
- `log_insight_view(user_id, insight_id)`: Track views
- `log_insight_interaction(user_id, insight_id, type)`: Track shares, saves
- `get_user_engagement_stats(user_id)`: Get user metrics
- `record_time_spent(user_id, insight_id, seconds)`: Time tracking

**Tracked Events:**
- View (with time spent)
- Share (WhatsApp, social media)
- Save/bookmark
- Click on sections
- Rating submission
- Entry point (home, notification, search)

#### AIInsightFeedbackService
Manages user feedback for AI training and improvement.

**Key Methods:**
- `submit_feedback(user_id, insight_id, rating, comment, tags)`: Record feedback
- `get_feedback_summary(insight_id)`: Aggregate feedback
- `analyze_sentiment(comment)`: Sentiment classification
- `update_ml_training_flags()`: Mark for training

**Feedback Usage:**
- Train model on accuracy ratings
- Improve personalization based on relevance
- Monitor quality metrics
- Identify problematic insights
- Trending analysis

### API Endpoints (25+ Routes)

#### Insight Retrieval (6 endpoints)
```
GET /api/v1/insights/daily
  - Get today's base insight for user's zodiac
  - Params: optional zodiac_sign override
  
GET /api/v1/insights/daily/personalized
  - Get personalized version for current user
  - Auto-personalizes if not exists
  
GET /api/v1/insights/by-date?date=YYYY-MM-DD
  - Get insight for specific date
  
GET /api/v1/insights/by-zodiac/{zodiac_sign}?days=7
  - Get last N days for zodiac sign
  
GET /api/v1/insights/trending?limit=10
  - Get most viewed/engaged insights
  
GET /api/v1/insights/search?query=...&limit=20
  - Full-text search by title/content
```

#### History & Favorites (4 endpoints)
```
GET /api/v1/insights/history?limit=50&offset=0
  - Get user's viewing history with pagination
  
GET /api/v1/insights/favorites
  - Get saved/favorite insights
  
POST /api/v1/insights/history/{insight_id}/favorite
  - Toggle favorite status
  
DELETE /api/v1/insights/history/{insight_id}
  - Archive from history
```

#### Engagement Tracking (6 endpoints)
```
POST /api/v1/insights/engagement/{insight_id}/view
  - Log view with optional time spent
  
POST /api/v1/insights/engagement/{insight_id}/share?platform=whatsapp|social
  - Log share action
  
POST /api/v1/insights/engagement/{insight_id}/save
  - Save insight temporarily
  
GET /api/v1/insights/engagement/stats
  - Get user's engagement analytics
  
POST /api/v1/insights/engagement/{insight_id}/bookmark
  - Bookmark for collections
```

#### Preferences (3 endpoints)
```
GET /api/v1/insights/preferences
  - Get user's current preferences
  
PUT /api/v1/insights/preferences
  - Update multiple preferences
  - Request body: {insights_enabled, delivery_time, channels, etc.}
  
POST /api/v1/insights/preferences/reset
  - Reset to defaults
```

#### Feedback (3 endpoints)
```
POST /api/v1/insights/feedback/{insight_id}
  - Submit rating and comment
  - Params: rating (1-5), comment, tags
  
GET /api/v1/insights/feedback/{insight_id}/summary
  - Get aggregated feedback for insight
  
GET /api/v1/insights/feedback/my-feedback?limit=20
  - Get user's feedback history
```

#### Admin/Generation (3 endpoints)
```
POST /api/v1/insights/generate/batch
  - Manually trigger generation (admin only)
  
GET /api/v1/insights/generation-logs?limit=50
  - View generation process logs
  
GET /api/v1/insights/quality-metrics?days=7
  - Quality metrics and statistics
```

#### Personalization (2 endpoints)
```
POST /api/v1/insights/personalize
  - Manually trigger personalization for user
  
POST /api/v1/insights/send-notifications
  - Manually trigger notification send (admin)
```

### Flutter Implementation

#### Providers (8 State Managers)
1. **dailyInsightProvider**: Current daily insight
2. **personalizedInsightProvider**: User's personalized version
3. **insightHistoryProvider**: User's history with pagination
4. **favoriteInsightsProvider**: Saved insights
5. **insightPreferencesProvider**: User preferences (mutable)
6. **engagementStatsProvider**: Engagement metrics
7. **searchInsightsProvider**: Search results
8. **trendingInsightsProvider**: Popular insights

#### Screens (6 UI Screens)
1. **DailyInsightsHomeScreen**: Main feed with personalized insight
   - Display today's personalized insight prominently
   - Show engagement stats
   - Quick action buttons
   - Recent insights list
   - Total size: ~400 lines

2. **InsightDetailScreen**: Full insight with all sections
   - Display complete insight content
   - Show all structured sections (lucky times, colors, numbers)
   - Power affirmation
   - Career, romance, health guidance
   - Feedback/rating section
   - Share buttons
   - Total size: ~450 lines

3. **InsightPreferencesScreen**: Settings
   - Toggle insights on/off
   - Set delivery time and timezone
   - Select notification channels
   - Content type preferences
   - Writing style
   - Quiet hours configuration
   - Reset button
   - Total size: ~400 lines

4. **InsightHistoryScreen**: Viewing history
   - List of viewed insights with metadata
   - Time spent tracking
   - Rating display
   - Favorite toggle
   - Date formatting (relative: "2h ago")
   - Total size: ~250 lines

5. **FavoriteInsightsScreen**: Saved insights
   - Beautiful display of pinned insights
   - Show rating stars
   - Red heart indicators
   - Quick removal option
   - Total size: ~250 lines

6. **TrendingInsightsScreen**: Discovery
   - Numbered ranking display
   - Gold/silver/bronze badges for top 3
   - View counts and engagement scores
   - Quick jump to details
   - Total size: ~200 lines

#### Models (2 Model Files)
- **ai_insight_model.dart**: Core insight data models
- **user_insight_preference.dart**: Preference and configuration models

#### Total Flutter Code
- Providers: ~500 lines
- Models: ~400 lines
- Screens: ~1,850 lines
- **Total: ~2,750 lines**

## Setup Instructions

### Backend Setup

#### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

Key packages:
- FastAPI >= 0.95.0
- SQLAlchemy >= 2.0.0
- python-dateutil
- pytz
- openai >= 0.27.0
- celery >= 5.2.0
- redis >= 4.0.0

#### 2. Database Migration
```bash
# Create tables
alembic upgrade head

# Or create directly
python -c "from app.db import engine; from app.models import Base; Base.metadata.create_all(bind=engine)"
```

#### 3. Configure AI Models
Set environment variables:
```
OPENAI_API_KEY=sk-...
OPENAI_MODEL=gpt-4-turbo
# Or for Claude:
ANTHROPIC_API_KEY=sk-ant-...
```

#### 4. Setup Task Scheduler
```bash
# Start Celery worker
celery -A app.celery_app worker -l info

# Start Celery beat for daily generation
celery -A app.celery_app beat -l info
```

#### 5. Configure Scheduled Tasks
In `app/core/celery_config.py`:
```python
# Daily generation at 00:05 UTC
app.conf.beat_schedule = {
    'generate-daily-insights': {
        'task': 'app.tasks.generate_daily_insights',
        'schedule': crontab(hour=0, minute=5),
    },
    'send-personalized-insights': {
        'task': 'app.tasks.send_personalized_insights',
        'schedule': crontab(minute='*/30'),  # Every 30 minutes
    },
}
```

### Flutter Setup

#### 1. Add Dependencies
In `pubspec.yaml`:
```yaml
dependencies:
  flutter_riverpod: ^2.4.0
  
dev_dependencies:
  riverpod_generator: ^2.3.0
  build_runner: ^2.4.0
```

#### 2. Run Build
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 3. Add Routes
In `lib/routes/app_routes.dart`:
```dart
'/daily-insights': (context) => DailyInsightsHomeScreen(),
'/insight-detail': (context) => InsightDetailScreen(
  insightId: ModalRoute.of(context)!.settings.arguments as String,
),
'/insight-preferences': (context) => InsightPreferencesScreen(),
'/insight-history': (context) => InsightHistoryScreen(),
'/insight-favorites': (context) => FavoriteInsightsScreen(),
'/insight-trending': (context) => TrendingInsightsScreen(),
```

#### 4. Update Main Navigation
Add to bottom navigation or menu:
```dart
NavigationBarItem(
  icon: Icons.auto_awesome,
  label: 'Insights',
  onPressed: () => Navigator.pushNamed(context, '/daily-insights'),
),
```

## API Examples

### Get Personalized Insight
```bash
curl -H "Authorization: Bearer TOKEN" \
  https://api.astroluck.com/api/v1/insights/daily/personalized
```

Response:
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "base_insight_id": "...",
  "personalized_title": "Sarah, Today's Cosmic Alignment Brings Opportunity",
  "personalized_content": "Hi Sarah! Today the stars align in your favor...",
  "sections": {
    "lucky_times": {"start": "09:00", "end": "12:00"},
    "lucky_colors": ["gold", "emerald"],
    "lucky_numbers": [7, 14, 21],
    "power_affirmation": "I embrace cosmic support..."
  },
  "scheduled_delivery_time": "2024-01-15T08:00:00Z",
  "view_count": 0
}
```

### Submit Feedback
```bash
curl -X POST -H "Authorization: Bearer TOKEN" \
  "https://api.astroluck.com/api/v1/insights/feedback/550e8400...?rating=5&comment=Amazing%20insight!" \
  -d ''
```

Response:
```json
{
  "success": true,
  "message": "Feedback recorded"
}
```

### Get Trending Insights
```bash
curl -H "Authorization: Bearer TOKEN" \
  "https://api.astroluck.com/api/v1/insights/trending?limit=10"
```

Response:
```json
{
  "count": 10,
  "trending": [
    {
      "id": "...",
      "title": "Leo's Lion Energy Peaks Today",
      "zodiac_sign": "leo",
      "view_count": 4521,
      "engagement_score": 8943
    },
    ...
  ]
}
```

## Monitoring & Analytics

### Key Metrics to Track
1. **Engagement:**
   - Daily active users viewing insights
   - Average time spent per insight
   - Share rate (WhatsApp, social)
   - Save/bookmark rate

2. **Quality:**
   - Average feedback rating (1-5)
   - Accuracy rating trend
   - Generated insight diversity score
   - Content generation time

3. **Delivery:**
   - Email delivery rate
   - Push notification open rate
   - WhatsApp message delivery
   - Failed delivery rate

### Monitoring Endpoints
```
GET /api/v1/insights/quality-metrics?days=7
GET /api/v1/insights/generation-logs?limit=50
GET /api/v1/insights/engagement/stats
```

## Performance Optimization

### Caching Strategy
- Cache daily insights in Redis for 24 hours
- Invalidate on new feedback/ratings
- Cache trending insights for 1 hour

### Database Optimization
- Index on (user_id, created_at) for history
- Index on (zodiac_sign, date) for base insights
- Partial index on is_saved for fast favorites query
- Index on status for filtering

### API Response Time Targets
- Daily insight: < 200ms
- History: < 300ms
- Trending: < 150ms
- Search: < 500ms

## Troubleshooting

### Common Issues

**Problem:** No insights being generated
- Check Celery beat is running
- Verify OpenAI API key is set
- Check database connection
- Review logs: `celery -A app.celery_app events`

**Problem:** Notifications not sending
- Verify channels are enabled in preferences
- Check timezone configuration
- Review NotificationService logs
- Verify external API credentials (email, WhatsApp)

**Problem:** Poor personalization quality
- Check user preferences are complete
- Verify birth chart data if using
- Review personalization_level setting
- Check user history has enough data points

## Future Enhancements

1. **AI Improvements:**
   - Fine-tune model on user feedback
   - Multi-language support
   - Voice generation (audio insights)

2. **Personalization:**
   - ML-based content type prediction
   - Time-of-day optimization
   - Learning from interaction patterns

3. **Social Features:**
   - Share insights with friends
   - Group insights (compatibility)
   - Challenge others based on insights

4. **Integrations:**
   - Calendar event suggestions
   - Weather-adjusted guidance
   - Astrology app integrations

5. **Content:**
   - Video insights
   - Podcast generation
   - Collective horoscopes

## Support

For API documentation: See AI_INSIGHTS_API_REFERENCE.md
For integration examples: See AI_INSIGHTS_SETUP_GUIDE.md
For troubleshooting: See logs at `/var/log/astroluck/insights.log`
