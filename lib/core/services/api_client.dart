"""
AstroLuck Flutter API Integration Layer
Complete HTTP client with all endpoints
"""

import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../core/constants/app_constants.dart';
import '../core/models/models.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  static const String apiVersion = 'v1';
  
  late Dio _dio;
  String? _accessToken;
  String? _refreshToken;
  
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // Add interceptor for token refresh
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Try to refresh token
            bool refreshed = await refreshAccessToken();
            if (refreshed) {
              return handler.retry(error.requestOptions);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
  
  // ============ AUTHENTICATION ============
  
  /// Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'username': username,
        'password': password,
        'full_name': fullName,
      });
      
      _accessToken = response.data['access_token'];
      _refreshToken = response.data['refresh_token'];
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      _accessToken = response.data['access_token'];
      _refreshToken = response.data['refresh_token'];
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Refresh access token
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;
    
    try {
      final response = await _dio.post('/auth/refresh', data: {
        'refresh_token': _refreshToken,
      });
      
      _accessToken = response.data['access_token'];
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Logout
  void logout() {
    _accessToken = null;
    _refreshToken = null;
  }
  
  // ============ USER ENDPOINTS ============
  
  /// Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get('/users/me');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? birthDate,
    String? birthTime,
    String? birthPlace,
    String? gender,
    double? latitude,
    double? longitude,
    String? phoneNumber,
  }) async {
    try {
      final response = await _dio.put('/users/me', data: {
        if (fullName != null) 'full_name': fullName,
        if (birthDate != null) 'birth_date': birthDate,
        if (birthTime != null) 'birth_time': birthTime,
        if (birthPlace != null) 'birth_place': birthPlace,
        if (gender != null) 'gender': gender,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (phoneNumber != null) 'phone_number': phoneNumber,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ============ LOTTERY ENDPOINTS ============
  
  /// Generate lucky numbers
  Future<Map<String, dynamic>> generateLuckyNumbers({
    required String lotteryType,
  }) async {
    try {
      final response = await _dio.post('/generate-lucky-numbers', data: {
        'lottery_type': lotteryType,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Record lottery play
  Future<Map<String, dynamic>> recordLottery({
    required String lotteryType,
    required String numbers,
  }) async {
    try {
      final response = await _dio.post('/record-lottery', data: {
        'lottery_type': lotteryType,
        'numbers': numbers,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get lottery history
  Future<Map<String, dynamic>> getLotteryHistory({
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/lottery-history',
        queryParameters: {'limit': limit},
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ============ INSIGHTS ENDPOINTS ============
  
  /// Generate daily insight
  Future<Map<String, dynamic>> generateDailyInsight() async {
    try {
      final response = await _dio.post('/insights/generate');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get today's insight
  Future<Map<String, dynamic>> getTodayInsight() async {
    try {
      final response = await _dio.get('/insights/today');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get weekly summary
  Future<Map<String, dynamic>> getWeeklyInsightSummary() async {
    try {
      final response = await _dio.get('/insights/weekly');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get insight history
  Future<Map<String, dynamic>> getInsightHistory({
    int days = 7,
  }) async {
    try {
      final response = await _dio.get(
        '/insights/history',
        queryParameters: {'days': days},
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ============ ACHIEVEMENTS ENDPOINTS ============
  
  /// Get user achievements
  Future<Map<String, dynamic>> getAchievements() async {
    try {
      final response = await _dio.get('/achievements');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get achievement progress
  Future<Map<String, dynamic>> getAchievementProgress() async {
    try {
      final response = await _dio.get('/achievements/progress');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Check for unlockable badges
  Future<Map<String, dynamic>> checkForUnlocks() async {
    try {
      final response = await _dio.post('/achievements/check-unlock');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get community leaderboard
  Future<Map<String, dynamic>> getLeaderboard({
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/leaderboard',
        queryParameters: {'limit': limit},
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ============ SUBSCRIPTIONS ENDPOINTS ============
  
  /// Get available plans
  Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    try {
      final response = await _dio.get('/subscriptions/plans');
      return List<Map<String, dynamic>>.from(response.data['plans']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get current subscription
  Future<Map<String, dynamic>> getCurrentSubscription() async {
    try {
      final response = await _dio.get('/subscriptions/current');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Check feature availability
  Future<bool> isFeatureAvailable(String feature) async {
    try {
      final response = await _dio.get('/subscriptions/features/$feature');
      return response.data['available'] ?? false;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ============ POOLS ENDPOINTS ============
  
  /// Create lottery pool
  Future<Map<String, dynamic>> createLotteryPool({
    required String name,
    required String description,
    required String lotteryType,
    required String numbers,
    required double entryFee,
    int maxMembers = 10,
  }) async {
    try {
      final response = await _dio.post('/pools/create', data: {
        'name': name,
        'description': description,
        'lottery_type': lotteryType,
        'numbers': numbers,
        'entry_fee': entryFee,
        'max_members': maxMembers,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Join lottery pool
  Future<Map<String, dynamic>> joinLotteryPool(String poolId) async {
    try {
      final response = await _dio.post('/pools/$poolId/join');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get active pools
  Future<List<Map<String, dynamic>>> getActivePools({
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/pools',
        queryParameters: {'limit': limit},
      );
      
      return List<Map<String, dynamic>>.from(response.data['pools']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get my pools
  Future<List<Map<String, dynamic>>> getMyPools() async {
    try {
      final response = await _dio.get('/pools/user/my-pools');
      return List<Map<String, dynamic>>.from(response.data['pools']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ============ CHALLENGES ENDPOINTS ============
  
  /// Create challenge
  Future<Map<String, dynamic>> createChallenge({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String lotteryType,
    int maxParticipants = 100,
    double prizePool = 0,
    String difficulty = 'medium',
  }) async {
    try {
      final response = await _dio.post('/challenges/create', data: {
        'title': title,
        'description': description,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'lottery_type': lotteryType,
        'max_participants': maxParticipants,
        'prize_pool': prizePool,
        'difficulty': difficulty,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Join challenge
  Future<Map<String, dynamic>> joinChallenge(String challengeId) async {
    try {
      final response = await _dio.post('/challenges/$challengeId/join');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get active challenges
  Future<List<Map<String, dynamic>>> getActiveChallenges({
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/challenges',
        queryParameters: {'limit': limit},
      );
      
      return List<Map<String, dynamic>>.from(response.data['challenges']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get challenge leaderboard
  Future<List<Map<String, dynamic>>> getChallengeLeaderboard(
    String challengeId, {
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/challenges/$challengeId/leaderboard',
        queryParameters: {'limit': limit},
      );
      
      return List<Map<String, dynamic>>.from(response.data['leaderboard']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ============ ASTROLOGER ENDPOINTS ============
  
  /// Register as astrologer
  Future<Map<String, dynamic>> registerAsAstrologer({
    required String title,
    required String bio,
    required String specialties,
    required double hourlyRate,
    int experienceYears = 0,
    String? certification,
  }) async {
    try {
      final response = await _dio.post('/astrologers/register', data: {
        'title': title,
        'bio': bio,
        'specialties': specialties,
        'hourly_rate': hourlyRate,
        'experience_years': experienceYears,
        'certification': certification,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Search astrologers
  Future<List<Map<String, dynamic>>> searchAstrologers({
    String? specialty,
    double minRating = 0,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get('/astrologers/search', queryParameters: {
        if (specialty != null) 'specialty': specialty,
        'min_rating': minRating,
        'limit': limit,
      });
      
      return List<Map<String, dynamic>>.from(response.data['astrologers']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ============ CONSULTATION ENDPOINTS ============
  
  /// Book consultation
  Future<Map<String, dynamic>> bookConsultation({
    required String astrologerId,
    required String topic,
    required DateTime scheduledTime,
    int durationMinutes = 60,
  }) async {
    try {
      final response = await _dio.post('/consultations/book', data: {
        'astrologer_id': astrologerId,
        'topic': topic,
        'scheduled_time': scheduledTime.toIso8601String(),
        'duration_minutes': durationMinutes,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get my consultations
  Future<List<Map<String, dynamic>>> getMyConsultations({
    String? status,
  }) async {
    try {
      final response = await _dio.get(
        '/consultations',
        queryParameters: {
          if (status != null) 'status': status,
        },
      );
      
      return List<Map<String, dynamic>>.from(response.data['consultations']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Rate consultation
  Future<Map<String, dynamic>> rateConsultation({
    required String sessionId,
    required int rating,
    String? review,
  }) async {
    try {
      final response = await _dio.post(
        '/consultations/$sessionId/rate',
        data: {
          'rating': rating,
          if (review != null) 'review': review,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ============ COMMUNITY ENDPOINTS ============
  
  /// Create lucky share
  Future<Map<String, dynamic>> createLuckyShare({
    required String numbers,
    required String lotteryType,
    String? description,
  }) async {
    try {
      final response = await _dio.post('/community/shares', data: {
        'numbers': numbers,
        'lottery_type': lotteryType,
        if (description != null) 'description': description,
      });
      
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get public shares
  Future<List<Map<String, dynamic>>> getPublicShares({
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/community/shares/public',
        queryParameters: {'limit': limit},
      );
      
      return List<Map<String, dynamic>>.from(response.data['shares']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ============ ERROR HANDLING ============
  
  String _handleError(DioException error) {
    if (error.response != null) {
      return error.response?.data['detail'] ?? 'An error occurred';
    } else {
      return error.message ?? 'Network error';
    }
  }
}
