# 🚀 Intelligence & Analytics - Setup & Integration Guide

## 📋 Quick Start

This guide covers setting up and integrating the Intelligence & Analytics features into your AstroLuck application.

---

## 🔧 Backend Setup

### 1. Install Dependencies

The backend uses these additional libraries (already in requirements.txt):

```bash
pip install numpy    # Numerology calculations
pip install scipy    # Statistical analysis
pip install pandas   # Data manipulation
```

### 2. Database Migrations

Create the new database tables:

```bash
# From project root
alembic revision --autogenerate -m "Add intelligence models"
alembic upgrade head
```

This creates tables for:
- `numerology_profiles`
- `win_probabilities`
- `user_statistics`
- `ai_insights`

### 3. Place Backend Files

1. **Create directory** (if not exists):
   ```bash
   mkdir -p backend/app/services
   mkdir -p backend/app/models
   mkdir -p backend/app/api/routes
   ```

2. **Copy files**:
   - `intelligence_models.py` → `backend/app/models/`
   - `intelligence_service.py` → `backend/app/services/`
   - `intelligence.py` → `backend/app/api/routes/`

3. **Update main.py**:
   ```python
   # In app/main.py, add these imports:
   from app.api.routes import intelligence
   
   # In the router includes section:
   app.include_router(intelligence.router)
   ```

4. **Update models/__init__.py**:
   ```python
   # Add to exports:
   from .intelligence_models import (
       NumerologyProfile,
       WinProbability,
       UserStatistics,
       AIInsight
   )
   ```

### 4. Test Backend

Start the server:
```bash
# From project root
python start_server.py
```

Test endpoints:
```bash
# Test numerology endpoint
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8000/api/v1/intelligence/numerology/1

# Test AI insights
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8000/api/v1/intelligence/ai-insights/1
```

---

## 📱 Flutter Setup

### 1. Create Directory Structure

```bash
# From project root
mkdir -p lib/features/intelligence/screens
mkdir -p lib/features/intelligence/providers
mkdir -p lib/features/intelligence/widgets
```

### 2. Copy Flutter Files

1. **Screens**:
   - `ai_insights_screen.dart` → `lib/features/intelligence/screens/`
   - `numerology_screen.dart` → `lib/features/intelligence/screens/`
   - `probability_screen.dart` → `lib/features/intelligence/screens/`
   - `statistics_screen.dart` → `lib/features/intelligence/screens/`

2. **Providers**:
   - `intelligence_providers.dart` → `lib/features/intelligence/providers/`

### 3. Update API Client

Add these methods to `lib/core/services/api_client.dart`:

```dart
// AI Insights
Future<Map<String, dynamic>> generateDailyAIInsight({required String userId}) async {
  return get('/api/v1/intelligence/ai-insights/$userId');
}

// Numerology
Future<Map<String, dynamic>> getNumerologyProfile({required String userId}) async {
  return get('/api/v1/intelligence/numerology/$userId');
}

// Probability
Future<Map<String, dynamic>> getWinProbability({required String userId}) async {
  return get('/api/v1/intelligence/probability/$userId');
}

// Statistics
Future<Map<String, dynamic>> getUserStatistics({required String userId}) async {
  return get('/api/v1/intelligence/statistics/$userId');
}

// Hot/Cold
Future<Map<String, dynamic>> getHotColdAnalysis({required String userId}) async {
  return get('/api/v1/intelligence/hot-cold/$userId');
}

// Dashboard
Future<Map<String, dynamic>> getAnalyticsDashboard({required String userId}) async {
  return get('/api/v1/intelligence/dashboard/$userId');
}

// Predictions
Future<Map<String, dynamic>> getPredictions({required String userId}) async {
  return get('/api/v1/intelligence/predictions/$userId');
}
```

### 4. Add Navigation Routes

Update `lib/routes/app_routes.dart`:

```dart
class AppRoutes {
  static const String root = '/';
  
  // ... existing routes ...
  
  // Intelligence routes
  static const String aiInsights = '/ai-insights';
  static const String numerology = '/numerology';
  static const String probability = '/probability';
  static const String statistics = '/statistics';
  static const String dashboard = '/intelligence-dashboard';
}
```

### 5. Update Router Configuration

In `lib/routes/` (or where routes are defined):

```dart
// Add intelligence tab in main app
GoRoute(
  path: AppRoutes.aiInsights,
  builder: (context, state) => AIInsightsScreen(),
),
GoRoute(
  path: AppRoutes.numerology,
  builder: (context, state) => NumerologyScreen(),
),
GoRoute(
  path: AppRoutes.probability,
  builder: (context, state) => ProbabilityScreen(),
),
GoRoute(
  path: AppRoutes.statistics,
  builder: (context, state) => StatisticsScreen(),
),
```

### 6. Add Bottom Navigation Tab

Update your main app's bottom navigation:

```dart
BottomNavigationBarItem(
  icon: Icon(Icons.auto_awesome),
  label: 'Intelligence',
),
```

### 7. Create Intelligence Feature Container

Create `lib/features/intelligence/intelligence_container.dart`:

```dart
import 'package:flutter/material.dart';
import 'screens/ai_insights_screen.dart';
import 'screens/numerology_screen.dart';
import 'screens/probability_screen.dart';
import 'screens/statistics_screen.dart';

class IntelligenceContainer extends StatefulWidget {
  @override
  State<IntelligenceContainer> createState() => _IntelligenceContainerState();
}

class _IntelligenceContainerState extends State<IntelligenceContainer> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    AIInsightsScreen(),
    NumerologyScreen(),
    ProbabilityScreen(),
    StatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Insights'),
          BottomNavigationBarItem(icon: Icon(Icons.numbers), label: 'Numerology'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Probability'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }
}
```

---

## 🔐 Authentication Setup

### 1. Ensure JWT Token Handling

All intelligence endpoints require valid JWT token. Update your auth service:

```dart
// In lib/core/services/auth_service.dart
Future<String?> getAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

Future<void> setAuthToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
}
```

### 2. API Client Headers

Ensure API client adds Authorization header:

```dart
// In api_client.dart
Future<dynamic> get(String endpoint) async {
  final token = await getAuthToken();
  
  final response = await http.get(
    Uri.parse('$baseUrl$endpoint'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  
  // Handle response...
}
```

---

## ✅ Integration Checklist

### Backend
- [ ] All files copied to correct directories
- [ ] Database migrations run
- [ ] main.py updated with intelligence router
- [ ] models/__init__.py updated with intelligence imports
- [ ] Server starts without errors
- [ ] All 10 intelligence endpoints return 200 OK

### Flutter
- [ ] Directory structure created
- [ ] All 4 screen files copied
- [ ] Providers file copied
- [ ] API client methods added
- [ ] Routes configured
- [ ] Bottom navigation updated
- [ ] App compiles without errors
- [ ] Navigation between screens works

---

## 🧪 Testing Integration

### 1. Backend Tests

Create `backend/tests/test_intelligence.py`:

```python
import pytest
from app.services.intelligence_service import IntelligenceService
from app.models.intelligence_models import NumerologyProfile

@pytest.fixture
def service():
    return IntelligenceService()

def test_numerology_calculation():
    """Test numerology number calculation"""
    numerology = service.calculate_numerology(
        birth_date="1990-05-14",
        name="John Doe"
    )
    assert numerology['life_path_number'] in range(1, 34)
    assert numerology['destiny_number'] in range(1, 34)

def test_win_probability():
    """Test win probability calculation"""
    prob = service.calculate_win_probability(user_id=1, lottery_type='astro')
    assert 0.0 <= prob <= 1.0

def test_user_statistics():
    """Test statistics generation"""
    stats = service.generate_user_statistics(user_id=1)
    assert 'hot_numbers' in stats
    assert 'cold_numbers' in stats
    assert 'win_rate' in stats

def test_ai_insights():
    """Test AI insights generation"""
    insights = service.generate_ai_insights(user_id=1)
    assert len(insights) > 0
    assert 'title' in insights[0]
    assert 'recommendation' in insights[0]
```

Run tests:
```bash
pytest backend/tests/test_intelligence.py -v
```

### 2. API Integration Tests

```bash
# Test all intelligence endpoints
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8000/api/v1/intelligence/dashboard/1

# Should return 200 with full dashboard data
```

### 3. Flutter Widget Tests

Create `test/features/intelligence_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:astролuck/features/intelligence/screens/numerology_screen.dart';

void main() {
  group('Intelligence Features', () {
    testWidgets('Numerology screen loads', (WidgetTester tester) async {
      await tester.pumpWidget(NumerologyScreen());
      expect(find.text('Numerology'), findsOneWidget);
    });
  });
}
```

---

## 📊 Database Verification

Check that all tables are created:

```sql
-- Connect to database
-- Check tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_name LIKE 'numerology_%' 
   OR table_name LIKE 'win_probability%' 
   OR table_name LIKE 'user_statistics%' 
   OR table_name LIKE 'ai_insight%';

-- Should return 4 tables
```

---

## 🔌 API Testing with Postman

### 1. Create Postman Collection

1. Open Postman
2. Create new collection: "Intelligence & Analytics"
3. Add requests:

**Numerology Profile**:
```
GET http://localhost:8000/api/v1/intelligence/numerology/1
Authorization: Bearer {{token}}
```

**AI Insights**:
```
GET http://localhost:8000/api/v1/intelligence/ai-insights/1
Authorization: Bearer {{token}}
```

**Dashboard**:
```
GET http://localhost:8000/api/v1/intelligence/dashboard/1
Authorization: Bearer {{token}}
```

### 2. Set Variables

Create Postman environment variables:
- `base_url`: http://localhost:8000
- `token`: Your JWT token
- `user_id`: 1

---

## 🐛 Troubleshooting

### Issue: 401 Unauthorized on API calls

**Solution**: 
- Verify JWT token is valid
- Check Authorization header format: `Bearer <token>`
- Token may be expired - refresh it

### Issue: 404 Not Found on intelligence endpoints

**Solution**:
- Ensure `intelligence.py` is in `app/api/routes/`
- Check `main.py` has `app.include_router(intelligence.router)`
- Restart server

### Issue: Numerology calculations don't match other sites

**Solution**:
- We use Pythagorean numerology system
- Different systems (Chaldean, etc) produce different results
- This is expected

### Issue: Flutter screens not showing

**Solution**:
- Verify directory structure: `lib/features/intelligence/screens/`
- Check imports in provider files
- Ensure API client updated with new methods
- Verify routes configured correctly

### Issue: API returns 500 error

**Solution**:
- Check backend logs for error details
- Verify database migrations ran
- Ensure user has complete profile (birth date, name)
- Check database connection

### Issue: Slow API response times

**Solution**:
- First call caches data (30 min TTL)
- Subsequent calls use cache (fast)
- If slow on first call, check database performance
- May need to optimize queries for large datasets

---

## 📈 Performance Optimization

### 1. Database Indexing

Add indexes for fast queries:

```sql
CREATE INDEX idx_user_id ON numerology_profiles(user_id);
CREATE INDEX idx_lottery_type ON win_probabilities(lottery_type);
CREATE INDEX idx_created_at ON ai_insights(created_at);
```

### 2. Caching Strategy

Intelligence endpoints cache responses:
- Numerology: 24 hours (doesn't change)
- Probabilities: 6 hours (changes slowly)
- Statistics: 1 hour (updates regularly)
- AI Insights: 30 minutes (daily generation)

### 3. Batch Processing

For large user bases:
```bash
# Generate insights for all users at midnight
0 0 * * * python -m app.scripts.batch_generate_insights
```

---

## 🚀 Deployment Checklist

- [ ] Backend files added to correct paths
- [ ] Database tables created via migrations
- [ ] Environment variables configured
- [ ] API endpoints tested in production
- [ ] Flutter screens integrated and tested
- [ ] Authentication working with production tokens
- [ ] Error handling configured
- [ ] Monitoring and logging set up
- [ ] Backup configured
- [ ] Rate limiting configured
- [ ] CORS headers set correctly
- [ ] SSL/HTTPS working

---

## 📚 Related Documentation

- [Intelligence Features Overview](./INTELLIGENCE_FEATURES.md)
- [API Reference](./INTELLIGENCE_API.md)
- [Deployment Guide](./DEPLOYMENT_GUIDE.md)
- [Flutter Integration Guide](./FLUTTER_INTEGRATION.md)

---

## 💬 Support

For issues or questions:
1. Check troubleshooting section above
2. Review server logs: `backend/logs/app.log`
3. Check API response status codes
4. Verify all files in correct locations
5. Ensure all dependencies installed
