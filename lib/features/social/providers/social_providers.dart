// lib/features/social/providers/social_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_client.dart';

// Community Pools Providers
final communityPoolsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) async {
    final apiClient = ApiClient();
    final response = await apiClient.get('/api/v1/social/pools');
    return (response['data'] as List).cast<Map<String, dynamic>>();
  },
);

final poolDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, poolId) async {
    final apiClient = ApiClient();
    final response = await apiClient.get('/api/v1/social/pools/$poolId');
    return response['data'] as Map<String, dynamic>;
  },
);

// Live Generation Events Providers
final liveEventsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) async {
    final apiClient = ApiClient();
    final response = await apiClient.get('/api/v1/social/events?status=live');
    return (response['data'] as List).cast<Map<String, dynamic>>();
  },
);

final eventDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, eventId) async {
    final apiClient = ApiClient();
    final response = await apiClient.get('/api/v1/social/events/$eventId');
    return response['data'] as Map<String, dynamic>;
  },
);

// Astrologer Directory Providers
final astrologersProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) async {
    final apiClient = ApiClient();
    final response = await apiClient.get('/api/v1/social/astrologers?limit=50');
    return (response['data'] as List).cast<Map<String, dynamic>>();
  },
);

final astrologerDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, astrologerId) async {
    final apiClient = ApiClient();
    final response = await apiClient.get('/api/v1/social/astrologers/$astrologerId');
    return response['data'] as Map<String, dynamic>;
  },
);

// Challenges Providers
final challengesProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) async {
    final apiClient = ApiClient();
    final response = await apiClient.get('/api/v1/social/challenges?status=active');
    return (response['data'] as List).cast<Map<String, dynamic>>();
  },
);

final challengeDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, challengeId) async {
    final apiClient = ApiClient();
    final response = await apiClient.get('/api/v1/social/challenges/$challengeId');
    return response['data'] as Map<String, dynamic>;
  },
);

// Badges & Leaderboard Providers
final userBadgesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, userId) async {
    final apiClient = ApiClient();
    final response = await apiClient.get('/api/v1/social/badges/$userId');
    return (response['data'] as List).cast<Map<String, dynamic>>();
  },
);

final leaderboardProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) async {
    final apiClient = ApiClient();
    final response = await apiClient.get('/api/v1/social/leaderboard?limit=100');
    return (response['data'] as List).cast<Map<String, dynamic>>();
  },
);

final userStatsProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, userId) async {
    final apiClient = ApiClient();
    final response = await apiClient.get('/api/v1/social/user/$userId/stats');
    return response['data'] as Map<String, dynamic>;
  },
);
