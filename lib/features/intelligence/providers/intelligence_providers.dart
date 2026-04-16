// lib/features/intelligence/providers/intelligence_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_client.dart';

// Numerology Provider
final numerologyProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, userId) async {
    final apiClient = ApiClient();
    final response = await apiClient.get('/api/v1/intelligence/numerology/$userId');
    return response as Map<String, dynamic>;
  },
);

// Numerology Details Provider
final numerologyDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, userId) async {
    final apiClient = ApiClient();
    final response = await apiClient.get('/api/v1/intelligence/numerology/details/$userId');
    return response as Map<String, dynamic>;
  },
);

// Probability Provider
final probabilityProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, userId) async {
    final apiClient = ApiClient();
    final response = await apiClient.get('/api/v1/intelligence/probability/$userId');
    return response as Map<String, dynamic>;
  },
);

// Statistics Provider
final statisticsProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, userId) async {
    final apiClient = ApiClient();
    final response = await apiClient.get('/api/v1/intelligence/statistics/$userId');
    return response as Map<String, dynamic>;
  },
);

// Hot/Cold Numbers Provider
final hotColdProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, userId) async {
    final apiClient = ApiClient();
    final response = await apiClient.get('/api/v1/intelligence/hot-cold/$userId');
    return response as Map<String, dynamic>;
  },
);

// Patterns Provider
final patternsProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, userId) async {
    final apiClient = ApiClient();
    final response = await apiClient.get('/api/v1/intelligence/patterns/$userId');
    return response as Map<String, dynamic>;
  },
);

// AI Insights Provider
final aiInsightsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, userId) async {
    final apiClient = ApiClient();
    final response = await apiClient.get('/api/v1/intelligence/ai-insights/$userId');
    return List<Map<String, dynamic>>.from(response as List);
  },
);

// Dashboard Provider
final dashboardProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, userId) async {
    final apiClient = ApiClient();
    final response = await apiClient.get('/api/v1/intelligence/dashboard/$userId');
    return response as Map<String, dynamic>;
  },
);

// Predictions Provider
final predictionsProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, userId) async {
    final apiClient = ApiClient();
    final response = await apiClient.get('/api/v1/intelligence/predictions/$userId');
    return response as Map<String, dynamic>;
  },
);
