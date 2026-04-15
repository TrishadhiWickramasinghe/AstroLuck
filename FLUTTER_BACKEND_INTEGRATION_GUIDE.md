# AstroLuck Flutter-Backend Integration Guide

Complete step-by-step guide for integrating Flutter app with FastAPI backend.

## Table of Contents

1. [API Client Setup](#api-client-setup)
2. [Authentication Flow](#authentication-flow)
3. [State Management Integration](#state-management-integration)
4. [Feature Integration](#feature-integration)
5. [Error Handling](#error-handling)
6. [Testing Integration](#testing-integration)
7. [Production Checklist](#production-checklist)

---

## API Client Setup

### 1. Update pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HTTP & API
  dio: ^5.3.0
  http: ^1.1.0
  
  # Authentication
  flutter_secure_storage: ^9.0.0
  jwt_decoder: ^2.0.1
  
  # State Management
  provider: ^6.0.0
  riverpod: ^2.4.0
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Models
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0
  
  # Utilities
  intl: ^0.19.0
  connectivity_plus: ^5.0.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
```

### 2. Initialize Hive Local Storage

```dart
// lib/core/local_storage/hive_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class HiveService {
  static const String userBoxKey = 'users';
  static const String tokenBoxKey = 'tokens';
  static const String settingsBoxKey = 'settings';
  
  static Future<void> initializeHive() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(SubscriptionAdapter());
    
    // Open boxes
    await Hive.openBox<dynamic>(userBoxKey);
    await Hive.openBox<dynamic>(tokenBoxKey);
    await Hive.openBox<dynamic>(settingsBoxKey);
  }
  
  static Box<dynamic> getUserBox() => Hive.box(userBoxKey);
  static Box<dynamic> getTokenBox() => Hive.box(tokenBoxKey);
  static Box<dynamic> getSettingsBox() => Hive.box(settingsBoxKey);
}
```

### 3. Token Management

```dart
// lib/core/services/token_manager.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  final _secureStorage = const FlutterSecureStorage();
  
  /// Save tokens securely
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }
  
  /// Get access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }
  
  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }
  
  /// Check if token is expired
  bool isTokenExpired(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(
        decodedToken['exp'] * 1000,
      );
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      return true;
    }
  }
  
  /// Clear tokens
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
    ]);
  }
}
```

---

## Authentication Flow

### 1. Authentication Service

```dart
// lib/core/services/auth_service.dart

import 'dart:async';
import 'package:flutter_riverpod/riverpod.dart';
import '../models/auth_models.dart';

class AuthService {
  final ApiClient _api;
  final TokenManager _tokenManager;
  
  AuthService({
    required ApiClient api,
    required TokenManager tokenManager,
  }) : _api = api,
       _tokenManager = tokenManager;
  
  /// Register new user
  Future<AuthResponse> register({
    required String email,
    required String username,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _api.register(
        email: email,
        username: username,
        password: password,
        fullName: fullName,
      );
      
      final authResponse = AuthResponse.fromJson(response);
      
      // Save tokens
      await _tokenManager.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );
      
      return authResponse;
    } catch (e) {
      throw AuthException('Registration failed: $e');
    }
  }
  
  /// Login user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.login(
        email: email,
        password: password,
      );
      
      final authResponse = AuthResponse.fromJson(response);
      
      // Save tokens
      await _tokenManager.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );
      
      return authResponse;
    } catch (e) {
      throw AuthException('Login failed: $e');
    }
  }
  
  /// Refresh access token
  Future<void> refreshToken() async {
    try {
      final refreshToken = await _tokenManager.getRefreshToken();
      if (refreshToken == null) throw AuthException('No refresh token found');
      
      final success = await _api.refreshAccessToken();
      if (!success) throw AuthException('Token refresh failed');
    } catch (e) {
      await logout();
      rethrow;
    }
  }
  
  /// Logout
  Future<void> logout() async {
    await _tokenManager.clearTokens();
  }
  
  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _tokenManager.getAccessToken();
    if (token == null) return false;
    return !_tokenManager.isTokenExpired(token);
  }
}

// Riverpod providers
final authServiceProvider = Provider((ref) {
  return AuthService(
    api: ref.watch(apiClientProvider),
    tokenManager: ref.watch(tokenManagerProvider),
  );
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  
  AuthNotifier(this._authService) : super(const AuthState.initial());
  
  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String fullName,
  }) async {
    state = const AuthState.loading();
    try {
      final response = await _authService.register(
        email: email,
        username: username,
        password: password,
        fullName: fullName,
      );
      state = AuthState.authenticated(response.user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
  
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );
      state = AuthState.authenticated(response.user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
  
  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState.unauthenticated();
  }
}

// Auth state classes
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}
```

---

## State Management Integration

### 1. Feature Providers

```dart
// lib/core/providers/feature_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Lottery provider
final lotteryProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, lotteryType) async {
    final api = ref.watch(apiClientProvider);
    return await api.generateLuckyNumbers(lotteryType: lotteryType);
  },
);

// Insights provider
final insightProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return await api.getTodayInsight();
});

// Achievements provider
final achievementsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return await api.getAchievements();
});

// Leaderboard provider
final leaderboardProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return await api.getLeaderboard(limit: 10);
});

// Subscription provider
final subscriptionProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return await api.getCurrentSubscription();
});

// User profile provider
final userProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return await api.getCurrentUser();
});

// Notification provider (real-time)
final notificationStreamProvider = StreamProvider<Map<String, dynamic>>((ref) async* {
  final api = ref.watch(apiClientProvider);
  yield* api.streamNotifications();
});
```

### 2. Caching Strategy

```dart
// lib/core/providers/cache_providers.dart

class CacheManager {
  static const Duration _cacheExpiry = Duration(hours: 1);
  final Map<String, CachedData> _cache = {};
  
  Future<T> getCached<T>({
    required String key,
    required Future<T> Function() fetcher,
    Duration cacheDuration = _cacheExpiry,
  }) async {
    final now = DateTime.now();
    
    // Check cache
    if (_cache.containsKey(key)) {
      final cached = _cache[key]!;
      if (now.difference(cached.timestamp) < cacheDuration) {
        return cached.data as T;
      }
    }
    
    // Fetch new data
    final data = await fetcher();
    
    // Cache result
    _cache[key] = CachedData(data: data, timestamp: now);
    
    return data;
  }
  
  void clearCache([String? key]) {
    if (key != null) {
      _cache.remove(key);
    } else {
      _cache.clear();
    }
  }
}

class CachedData {
  final dynamic data;
  final DateTime timestamp;
  
  CachedData({required this.data, required this.timestamp});
}

final cacheManagerProvider = Provider((ref) => CacheManager());
```

---

## Feature Integration

### 1. Lottery Generation

```dart
// lib/features/home/providers/lottery_provider.dart

final lotteryStateProvider = StateNotifierProvider<LotteryNotifier, LotteryState>((ref) {
  return LotteryNotifier(ref.watch(apiClientProvider));
});

class LotteryNotifier extends StateNotifier<LotteryState> {
  final ApiClient _api;
  
  LotteryNotifier(this._api) : super(const LotteryState.initial());
  
  Future<void> generateNumbers(String lotteryType) async {
    state = const LotteryState.loading();
    try {
      final response = await _api.generateLuckyNumbers(lotteryType: lotteryType);
      state = LotteryState.success(response);
    } catch (e) {
      state = LotteryState.error(e.toString());
    }
  }
  
  Future<void> recordLottery(String lotteryType, String numbers) async {
    try {
      await _api.recordLottery(
        lotteryType: lotteryType,
        numbers: numbers,
      );
      // Refresh achievements after recording
      state = LotteryState.recorded();
    } catch (e) {
      state = LotteryState.error(e.toString());
    }
  }
}

@freezed
class LotteryState with _$LotteryState {
  const factory LotteryState.initial() = _Initial;
  const factory LotteryState.loading() = _Loading;
  const factory LotteryState.success(Map<String, dynamic> data) = _Success;
  const factory LotteryState.recorded() = _Recorded;
  const factory LotteryState.error(String message) = _Error;
}
```

### 2. Insights Display

```dart
// lib/features/home/widgets/daily_insight_widget.dart

class DailyInsightWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightAsync = ref.watch(insightProvider);
    
    return insightAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => ErrorWidget(error: err.toString()),
      data: (insight) => _buildInsight(context, insight),
    );
  }
  
  Widget _buildInsight(BuildContext context, Map<String, dynamic> insight) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Insight',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(insight['title'] ?? ''),
            SizedBox(height: 8),
            Text(insight['description'] ?? ''),
            SizedBox(height: 8),
            if (insight['lucky_hours'] != null)
              Text('Lucky Hours: ${insight['lucky_hours']}'),
            SizedBox(height: 8),
            if (insight['lucky_numbers'] != null)
              Text('Lucky Numbers: ${insight['lucky_numbers']}'),
          ],
        ),
      ),
    );
  }
}
```

### 3. Subscription Management

```dart
// lib/features/settings/providers/subscription_provider.dart

final subscriptionNotifierProvider = StateNotifierProvider<
    SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier(ref.watch(apiClientProvider));
});

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final ApiClient _api;
  
  SubscriptionNotifier(this._api) : super(const SubscriptionState.loading());
  
  Future<void> loadSubscription() async {
    try {
      final current = await _api.getCurrentSubscription();
      final plans = await _api.getSubscriptionPlans();
      
      state = SubscriptionState.loaded(
        currentPlan: current,
        availablePlans: plans,
      );
    } catch (e) {
      state = SubscriptionState.error(e.toString());
    }
  }
  
  Future<void> upgradePlan(String planId) async {
    state = const SubscriptionState.loading();
    try {
      // Call payment API to process upgrade
      await _api.createSubscription(planId: planId);
      await loadSubscription();
    } catch (e) {
      state = SubscriptionState.error(e.toString());
    }
  }
}
```

---

## Error Handling

### 1. Custom Exception Classes

```dart
// lib/core/exceptions/api_exceptions.dart

abstract class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException([String message = 'Network error']) : super(message);
}

class AuthException extends ApiException {
  AuthException([String message = 'Authentication failed']) : super(message);
}

class NotFoundException extends ApiException {
  NotFoundException([String message = 'Resource not found']) : super(message);
}

class ValidationException extends ApiException {
  final Map<String, List<String>> errors;
  
  ValidationException({
    required this.errors,
    String message = 'Validation failed',
  }) : super(message);
}

class ServerException extends ApiException {
  ServerException([String message = 'Server error']) : super(message);
}
```

### 2. Error Handler Middleware

```dart
// lib/core/middleware/error_handler.dart

Future<T> handleApiError<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException('Connection timeout');
      
      case DioExceptionType.badResponse:
        switch (e.response?.statusCode) {
          case 401:
            throw AuthException('Unauthorized');
          case 403:
            throw AuthException('Forbidden');
          case 404:
            throw NotFoundException('Resource not found');
          case 422:
            throw ValidationException(
              errors: Map<String, List<String>>.from(
                e.response?.data['detail'] ?? {}
              ),
            );
          case 500:
          case 502:
          case 503:
            throw ServerException(
              e.response?.data['detail'] ?? 'Server error'
            );
          default:
            throw ServerException('Unknown error');
        }
      
      case DioExceptionType.cancel:
        throw ApiException('Request cancelled');
      
      default:
        throw ApiException(e.message ?? 'Unknown error');
    }
  }
}
```

### 3. Global Error Handler

```dart
// lib/core/middleware/global_error_handler.dart

class GlobalErrorHandler {
  static void handleError(BuildContext context, Object error) {
    String message = 'An error occurred';
    
    if (error is NetworkException) {
      message = 'Network connection failed. Please check your internet.';
    } else if (error is AuthException) {
      message = 'Authentication failed. Please login again.';
      _navigateToLogin(context);
    } else if (error is ValidationException) {
      message = 'Please check your input';
    } else if (error is ServerException) {
      message = error.message;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  static void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }
}
```

---

## Testing Integration

### 1. API Mocking

```dart
// test/mocks/mock_api_client.dart

import 'package:mockito/mockito.dart';

final mockApiClient = MockApiClient();

class MockApiClient extends Mock implements ApiClient {
  @override
  Future<Map<String, dynamic>> generateLuckyNumbers({
    required String lotteryType,
  }) async {
    return {
      'numbers': '12 25 38 42 55',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    return {
      'id': 1,
      'email': 'test@example.com',
      'username': 'testuser',
      'full_name': 'Test User',
    };
  }
}
```

### 2. Integration Tests

```dart
// test/integration/api_integration_test.dart

void main() {
  late ApiClient apiClient;
  late HttpClient httpClient;
  
  setUpAll(() {
    httpClient = HttpClientMock();
    apiClient = ApiClient();
  });
  
  group('Authentication Integration', () {
    test('Login should return user data and tokens', () async {
      final response = await apiClient.login(
        email: 'test@example.com',
        password: 'password123',
      );
      
      expect(response['access_token'], isNotNull);
      expect(response['refresh_token'], isNotNull);
    });
    
    test('Register should create new user', () async {
      final response = await apiClient.register(
        email: 'newuser@example.com',
        username: 'newuser',
        password: 'password123',
        fullName: 'New User',
      );
      
      expect(response['user']['email'], 'newuser@example.com');
    });
  });
  
  group('Lottery Integration', () {
    test('Generate lucky numbers should return valid format', () async {
      final response = await apiClient.generateLuckyNumbers(
        lotteryType: 'powerball',
      );
      
      expect(response['numbers'], isNotNull);
      expect(response['timestamp'], isNotNull);
    });
  });
}
```

---

## Production Checklist

- [ ] API endpoints verified with real backend
- [ ] Authentication flow tested end-to-end
- [ ] Token refresh working correctly
- [ ] Error handling for all API failures
- [ ] Network connectivity checks implemented
- [ ] Caching strategy optimized
- [ ] Local storage working (Hive)
- [ ] Sensitive data encrypted (tokens)
- [ ] All feature APIs integrated
- [ ] Real-time features (WebSocket) tested
- [ ] Offline support implemented
- [ ] Performance optimized (lazy loading)
- [ ] Security headers verified
- [ ] HTTPS only in production
- [ ] Rate limiting handled gracefully
- [ ] Monitoring and logging configured
- [ ] User authentication persists across restarts
- [ ] Automatic token refresh implemented
- [ ] Error messages user-friendly
- [ ] API documentation reviewed

---

**Last Updated:** 2024-01-15
**Version:** 1.0
