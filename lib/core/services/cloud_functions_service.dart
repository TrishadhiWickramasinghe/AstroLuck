import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

/// Cloud Functions Service - Makes HTTP calls to Cloud Functions
class CloudFunctionsService {
  static final CloudFunctionsService _instance = CloudFunctionsService._internal();

  // Update with your Firebase project region and ID
  static const String BASE_URL = 'https://your-region-your-project-id.cloudfunctions.net';

  CloudFunctionsService._internal();

  static CloudFunctionsService get instance => _instance;

  /// Get auth token for Cloud Function calls
  Future<String?> _getAuthToken() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  /// Helper method for HTTP requests
  Future<Map<String, dynamic>> _makeRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final uri = Uri.parse('$BASE_URL/$endpoint');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      http.Response response;

      if (method == 'POST') {
        response = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 30));
      } else if (method == 'GET') {
        response = await http.get(
          uri,
          headers: headers,
        ).timeout(const Duration(seconds: 30));
      } else {
        throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['error'] ?? 'Request failed');
      }
    } catch (e) {
      print('Cloud Function error: $e');
      rethrow;
    }
  }

  // ========================================================================
  // USER PROFILE FUNCTIONS
  // ========================================================================

  /// Create or update user profile
  Future<bool> createUserProfile({
    required String userId,
    required String name,
    required String dateOfBirth,
    required String timeOfBirth,
    required String placeOfBirth,
    required String gender,
  }) async {
    final response = await _makeRequest(
      method: 'POST',
      endpoint: 'createUserProfile',
      body: {
        'userId': userId,
        'name': name,
        'dateOfBirth': dateOfBirth,
        'timeOfBirth': timeOfBirth,
        'placeOfBirth': placeOfBirth,
        'gender': gender,
      },
    );
    return response['success'] ?? false;
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await _makeRequest(
      method: 'GET',
      endpoint: 'getUserProfile?userId=$userId',
    );
    return response['success'] ? response['data'] : null;
  }

  // ========================================================================
  // LOTTERY FUNCTIONS
  // ========================================================================

  /// Save lottery play to history
  Future<String?> saveLotteryPlay({
    required String userId,
    required String lotteryType,
    required List<int> numbers,
    double amount = 0,
    String? date,
  }) async {
    final response = await _makeRequest(
      method: 'POST',
      endpoint: 'saveLotteryPlay',
      body: {
        'userId': userId,
        'lotteryType': lotteryType,
        'numbers': numbers,
        'amount': amount,
        'date': date ?? DateTime.now().toIso8601String(),
      },
    );
    return response['success'] ? response['playId'] : null;
  }

  /// Get lottery history for a user
  Future<List<Map<String, dynamic>>> getLotteryHistory({
    required String userId,
    int limit = 50,
  }) async {
    final response = await _makeRequest(
      method: 'GET',
      endpoint: 'getLotteryHistory?userId=$userId&limit=$limit',
    );
    
    if (response['success']) {
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    }
    return [];
  }

  // ========================================================================
  // LUCKY NUMBERS FUNCTIONS
  // ========================================================================

  /// Save daily lucky numbers
  Future<String?> saveDailyLuckyNumbers({
    required String userId,
    required String day,
    required List<int> numbers,
    required String color,
    required String energyLevel,
    required String luckyTime,
  }) async {
    final response = await _makeRequest(
      method: 'POST',
      endpoint: 'saveDailyLuckyNumbers',
      body: {
        'userId': userId,
        'day': day,
        'numbers': numbers,
        'color': color,
        'energyLevel': energyLevel,
        'luckyTime': luckyTime,
      },
    );
    return response['success'] ? response['recordId'] : null;
  }

  /// Get lucky numbers for a user
  Future<List<Map<String, dynamic>>> getLuckyNumbers({
    required String userId,
    int days = 30,
  }) async {
    final response = await _makeRequest(
      method: 'GET',
      endpoint: 'getLuckyNumbers?userId=$userId&days=$days',
    );
    
    if (response['success']) {
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    }
    return [];
  }

  // ========================================================================
  // ANALYTICS FUNCTIONS
  // ========================================================================

  /// Get user statistics
  Future<Map<String, dynamic>?> getUserStatistics(String userId) async {
    final response = await _makeRequest(
      method: 'GET',
      endpoint: 'getUserStatistics?userId=$userId',
    );
    return response['success'] ? response['data'] : null;
  }
}
