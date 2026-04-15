# Flutter + Python Backend Integration Guide

## Overview

This document explains how to integrate the Python FastAPI backend with your Flutter AstroLuck application.

## Backend Features Available

### 1. **User Authentication**
- Register with email/username/password
- JWT-based authentication
- Access tokens (short-lived)
- Refresh tokens (long-lived)
- Session management

### 2. **User Profile Management**
- Store birth details (date, time, location)
- Calculate and cache astrological values
- User profile updates
- Profile verification

### 3. **Lucky Number Generation**
- Backend calculation of astrology values
- Lottery number generation for multiple types
- Caching of daily numbers
- Energy level calculation

### 4. **Lottery History**
- Store all lottery plays in cloud
- Track results when available
- Calculate win statistics
- Prize tracking

### 5. **Analytics**
- Success rates
- Favorite lottery types
- Pattern analysis
- Winning statistics
- Leaderboard rankings

### 6. **Community Features**
- Share lucky numbers publicly
- Public leaderboard
- Like/engage with shares
- View trending numbers

## Flutter-Backend Integration Steps

### Step 1: Setup Backend

```bash
cd backend
cp .env.example .env
# Edit .env with your database settings

# If using Docker
docker-compose up -d

# If local setup
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
alembic upgrade head
python run.py
```

### Step 2: Update Flutter Configuration

In your Flutter app, create a new constants file or update existing:

**lib/core/constants/api_config.dart**

```dart
class ApiConfig {
  // Change this based on environment
  static const String apiBaseUrl = 'http://localhost:8000/api/v1';
  // For production: 'https://your-backend-domain.com/api/v1'
  
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // Endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  
  static const String profileMe = '/users/me';
  static const String profileUpdate = '/users/me';
  
  static const String generateLuckyNumbers = '/users/generate-lucky-numbers';
  static const String recordLottery = '/users/record-lottery';
  static const String lotteryHistory = '/users/lottery-history';
  
  static const String communityShares = '/community/shares';
  static const String communityLeaderboard = '/community/leaderboard';
}
```

### Step 3: Create API Service

**lib/data/services/api_service.dart**

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:astroluck/core/constants/api_config.dart';

class ApiService {
  final String apiBaseUrl;
  String? _accessToken;
  String? _refreshToken;

  ApiService({String? baseUrl})
      : apiBaseUrl = baseUrl ?? ApiConfig.apiBaseUrl;

  // Auth Methods
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    String? fullName,
  }) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl${ApiConfig.authRegister}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
        'full_name': fullName,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
      _refreshToken = data['refresh_token'];
      return data;
    } else {
      throw Exception('Registration failed: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl${ApiConfig.authLogin}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
      _refreshToken = data['refresh_token'];
      return data;
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }

  // Lottery Methods
  Future<Map<String, dynamic>> generateLuckyNumbers(String lotteryType) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl${ApiConfig.generateLuckyNumbers}'),
      headers: _getAuthHeaders(),
      body: jsonEncode({'lottery_type': lotteryType}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate lucky numbers');
    }
  }

  Future<void> recordLottery({
    required String lotteryType,
    required String numbers,
    required int dailyLuckyNumber,
    required String luckyColor,
    required String energyLevel,
  }) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl${ApiConfig.recordLottery}'),
      headers: _getAuthHeaders(),
      body: jsonEncode({
        'lottery_type': lotteryType,
        'numbers': numbers,
        'daily_lucky_number': dailyLuckyNumber,
        'lucky_color': luckyColor,
        'energy_level': energyLevel,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to record lottery');
    }
  }

  Future<List<Map<String, dynamic>>> getLotteryHistory() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl${ApiConfig.lotteryHistory}'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load lottery history');
    }
  }

  // Community Methods
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl${ApiConfig.communityLeaderboard}'),
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load leaderboard');
    }
  }

  // Helper Methods
  Map<String, String> _getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_accessToken',
    };
  }

  void setTokens(String accessToken, String refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
}
```

### Step 4: Update Providers/State Management

If using Riverpod:

```dart
final apiServiceProvider = Provider((ref) => ApiService());

final authProvider = StateNotifierProvider((ref) {
  final api = ref.watch(apiServiceProvider);
  return AuthNotifier(api);
});
```

### Step 5: Update UI to Use Cloud Features

Before (Local Only):
```dart
// Generate lucky numbers locally
final luckyNumbers = LuckyNumberService.generate(user.birthDate);
```

After (With Backend):
```dart
final luckyNumbers = await apiService.generateLuckyNumbers('6/49');

// Save to backend
await apiService.recordLottery(
  lotteryType: luckyNumbers['lottery_type'],
  numbers: luckyNumbers['numbers'],
  dailyLuckyNumber: luckyNumbers['daily_lucky_number'],
  luckyColor: luckyNumbers['lucky_color'],
  energyLevel: luckyNumbers['energy_level'],
);
```

### Step 6: Add Cloud Sync to LocalStorageService

```dart
class LocalStorageService {
  final ApiService _apiService;

  // Sync user profile to backend
  Future<void> syncUserProfile(UserProfile profile) async {
    try {
      await _apiService.updateProfile(profile);
      await _prefs.setString('user_profile', jsonEncode(profile));
    } catch (e) {
      print('Sync failed: $e');
      // Still save locally for offline support
      await _prefs.setString('user_profile', jsonEncode(profile));
    }
  }

  // Sync lottery history to backend
  Future<void> syncLotteryHistory() async {
    try {
      final localHistory = getLotteryHistory();
      for (final lottery in localHistory) {
        await _apiService.recordLottery(...lottery);
      }
    } catch (e) {
      print('History sync failed: $e');
    }
  }
}
```

## API Response Models

You can generate Dart models from the backend schemas:

```dart
// lib/models/api_models.dart

class LuckyNumberResponse {
  final String numbers;
  final String lotteryType;
  final int dailyLuckyNumber;
  final int lifePathNumber;
  final String luckyColor;
  final String energyLevel;
  final int energyValue;
  final String luckyTime;
  final DateTime timestamp;

  LuckyNumberResponse({
    required this.numbers,
    required this.lotteryType,
    required this.dailyLuckyNumber,
    required this.lifePathNumber,
    required this.luckyColor,
    required this.energyLevel,
    required this.energyValue,
    required this.luckyTime,
    required this.timestamp,
  });

  factory LuckyNumberResponse.fromJson(Map<String, dynamic> json) {
    return LuckyNumberResponse(
      numbers: json['numbers'],
      lotteryType: json['lottery_type'],
      dailyLuckyNumber: json['daily_lucky_number'],
      lifePathNumber: json['life_path_number'],
      luckyColor: json['lucky_color'],
      energyLevel: json['energy_level'],
      energyValue: json['energy_value'],
      luckyTime: json['lucky_time'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
```

## Error Handling

Implement proper error handling:

```dart
Future<void> loginWithErrorHandling(String email, String password) async {
  try {
    await apiService.login(email: email, password: password);
  } on SocketException {
    showError('No internet connection');
  } on HttpException {
    showError('Invalid credentials');
  } catch (e) {
    showError('Login failed: $e');
  }
}
```

## Testing

### Test Auth Flow

```bash
# Register
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "username": "testuser",
    "password": "password123",
    "full_name": "Test User"
  }'

# Login
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'

# Use token to generate lucky numbers
curl -X POST http://localhost:8000/api/v1/users/generate-lucky-numbers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{"lottery_type": "6/49"}'
```

## Migration Path (Optional)

### Option 1: Keep Local + Add Cloud Sync

- App continues working offline
- New features sync to cloud when online
- Users can migrate data at their convenience

### Option 2: Full Cloud Migration

- Remove local persistent storage
- All operations require backend
- Simpler but less resilient to connectivity issues

### Option 3: Hybrid (Recommended)

- Keep local storage for offline support
- Sync to cloud for backup and community features
- Best of both worlds

## Deployment

### Frontend (Flutter)

Update API endpoint in `pubspec.yaml` or as environment variable:

```bash
flutter run \
  --dart-define=API_BASE_URL=https://your-backend.com/api/v1
```

### Backend (Python)

Deploy using Docker or directly:

```bash
# Build Docker image
docker build -t astroluck-backend .

# Push to registry
docker tag astroluck-backend your-registry/astroluck-backend
docker push your-registry/astroluck-backend

# Deploy on server
# Update docker-compose.yml or Kubernetes manifests with new image
```

## Monitoring & Logging

### Backend Logs

```bash
# View logs in Docker
docker-compose logs -f backend

# Enable more verbose logging
# Update app/main.py to use logging
```

### API Health Check

```bash
curl http://localhost:8000/health
```

## Performance Optimization

### Frontend

- Cache API responses
- Implement request deduplication
- Use pagination for list endpoints
- Consider offline-first approach

### Backend

- Add database indexes (already done)
- Implement caching layer (Redis - future enhancement)
- Use CDN for static assets
- Monitor query performance

## Support

For integration issues, check:
1. [Backend README](README.md)
2. [Setup Guide](SETUP.md)
3. API Documentation: http://localhost:8000/docs

---

**Last Updated**: April 16, 2024
