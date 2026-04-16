"""AI Daily Insights Provider - State management for personalized insights"""

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astroluck/core/models/ai_insight_model.dart';
import 'package:astroluck/core/models/user_insight_preference.dart';
import 'package:astroluck/core/services/api_service.dart';

// ==================== API Service Providers ====================

final apiServiceProvider = Provider((ref) => ApiService());


// ==================== Daily Insights Providers ====================

final dailyInsightProvider = FutureProvider.autoDispose<AIInsight?>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.get('/insights/daily');
    if (response != null) {
      return AIInsight.fromJson(response);
    }
    return null;
  } catch (e) {
    print('Error fetching daily insight: $e');
    rethrow;
  }
});


final personalizedInsightProvider = FutureProvider.autoDispose<PersonalizedAIInsight?>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.get('/insights/daily/personalized');
    if (response != null) {
      return PersonalizedAIInsight.fromJson(response);
    }
    return null;
  } catch (e) {
    print('Error fetching personalized insight: $e');
    rethrow;
  }
});


final insightByDateProvider = FutureProvider.family.autoDispose<AIInsight?, String>((ref, dateStr) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.get('/insights/by-date?date=$dateStr');
    if (response != null) {
      return AIInsight.fromJson(response);
    }
    return null;
  } catch (e) {
    print('Error fetching insight by date: $e');
    rethrow;
  }
});


final insightsByZodiacProvider = FutureProvider.family.autoDispose<List<AIInsight>, String>((ref, zodiacSign) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.get('/insights/by-zodiac/$zodiacSign?days=7');
    if (response != null && response['insights'] != null) {
      return (response['insights'] as List)
          .map((insight) => AIInsight.fromJson(insight))
          .toList();
    }
    return [];
  } catch (e) {
    print('Error fetching insights by zodiac: $e');
    rethrow;
  }
});


// ==================== History & Favorites Providers ====================

final insightHistoryProvider = FutureProvider.autoDispose<List<InsightHistoryItem>?>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.get('/insights/history?limit=50');
    if (response != null && response['history'] != null) {
      return (response['history'] as List)
          .map((item) => InsightHistoryItem.fromJson(item))
          .toList();
    }
    return null;
  } catch (e) {
    print('Error fetching insight history: $e');
    rethrow;
  }
});


final favoriteInsightsProvider = FutureProvider.autoDispose<List<InsightHistoryItem>?>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.get('/insights/favorites');
    if (response != null && response['favorites'] != null) {
      return (response['favorites'] as List)
          .map((item) => InsightHistoryItem.fromJson(item))
          .toList();
    }
    return null;
  } catch (e) {
    print('Error fetching favorite insights: $e');
    rethrow;
  }
});


// ==================== Preferences Provider ====================

final insightPreferencesProvider = FutureProvider.autoDispose<UserInsightPreference?>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.get('/insights/preferences');
    if (response != null) {
      return UserInsightPreference.fromJson(response);
    }
    return null;
  } catch (e) {
    print('Error fetching insight preferences: $e');
    rethrow;
  }
});


// Mutable preferences state notifier
class PreferencesNotifier extends StateNotifier<UserInsightPreference?> {
  final ApiService apiService;

  PreferencesNotifier(this.apiService) : super(null) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final response = await apiService.get('/insights/preferences');
      if (response != null) {
        state = UserInsightPreference.fromJson(response);
      }
    } catch (e) {
      print('Error loading preferences: $e');
    }
  }

  Future<bool> updatePreferences(Map<String, dynamic> updates) async {
    try {
      final response = await apiService.put(
        '/insights/preferences',
        data: updates,
      );
      
      if (response != null && response['success'] == true) {
        await _loadPreferences();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating preferences: $e');
      return false;
    }
  }

  Future<bool> resetPreferences() async {
    try {
      final response = await apiService.post('/insights/preferences/reset');
      
      if (response != null && response['success'] == true) {
        await _loadPreferences();
        return true;
      }
      return false;
    } catch (e) {
      print('Error resetting preferences: $e');
      return false;
    }
  }

  Future<bool> updateDeliveryTime(String time, String timezone) async {
    return updatePreferences({
      'delivery_time': time,
      'delivery_timezone': timezone,
    });
  }

  Future<bool> updateChannels(Map<String, bool> channels) async {
    return updatePreferences({
      'channels': channels,
    });
  }

  Future<bool> toggleInsights(bool enabled) async {
    return updatePreferences({
      'insights_enabled': enabled,
    });
  }
}

final preferencesProvider = StateNotifierProvider<PreferencesNotifier, UserInsightPreference?>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PreferencesNotifier(apiService);
});


// ==================== Engagement & Interaction Providers ====================

final engagementStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.get('/insights/engagement/stats');
    return response;
  } catch (e) {
    print('Error fetching engagement stats: $e');
    rethrow;
  }
});


class EngagementNotifier extends StateNotifier<void> {
  final ApiService apiService;
  final Ref ref;

  EngagementNotifier(this.apiService, this.ref) : super(null);

  Future<void> logView(String insightId, [int? timeSpentSeconds]) async {
    try {
      final url = timeSpentSeconds != null
          ? '/insights/engagement/$insightId/view?time_spent_seconds=$timeSpentSeconds'
          : '/insights/engagement/$insightId/view';
      
      await apiService.post(url);
      
      // Invalidate related providers to refresh data
      ref.invalidate(insightHistoryProvider);
      ref.invalidate(engagementStatsProvider);
    } catch (e) {
      print('Error logging view: $e');
    }
  }

  Future<void> logShare(String insightId, String platform) async {
    try {
      await apiService.post(
        '/insights/engagement/$insightId/share?platform=$platform',
      );
      
      ref.invalidate(engagementStatsProvider);
    } catch (e) {
      print('Error logging share: $e');
    }
  }

  Future<void> saveInsight(String insightId) async {
    try {
      await apiService.post('/insights/engagement/$insightId/save');
      
      ref.invalidate(insightHistoryProvider);
      ref.invalidate(engagementStatsProvider);
    } catch (e) {
      print('Error saving insight: $e');
    }
  }

  Future<void> toggleFavorite(String insightId) async {
    try {
      await apiService.post('/insights/history/$insightId/favorite');
      
      ref.invalidate(favoriteInsightsProvider);
      ref.invalidate(insightHistoryProvider);
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }
}

final engagementProvider = StateNotifierProvider<EngagementNotifier, void>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return EngagementNotifier(apiService, ref);
});


// ==================== Feedback Provider ====================

class FeedbackNotifier extends StateNotifier<void> {
  final ApiService apiService;
  final Ref ref;

  FeedbackNotifier(this.apiService, this.ref) : super(null);

  Future<bool> submitFeedback({
    required String insightId,
    required int rating,
    String? comment,
    List<String>? tags,
  }) async {
    try {
      final params = [
        'rating=$rating',
        if (comment != null) 'comment=${Uri.encodeComponent(comment)}',
        if (tags != null && tags.isNotEmpty)
          'tags=${tags.map(Uri.encodeComponent).join(',')}'
      ].join('&');
      
      final response = await apiService.post(
        '/insights/feedback/$insightId?$params',
      );
      
      if (response != null && response['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error submitting feedback: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getFeedbackSummary(String insightId) async {
    try {
      final response = await apiService.get(
        '/insights/feedback/$insightId/summary',
      );
      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching feedback summary: $e');
      return null;
    }
  }
}

final feedbackProvider = StateNotifierProvider<FeedbackNotifier, void>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return FeedbackNotifier(apiService, ref);
});


// ==================== Search & Discovery Providers ====================

final searchInsightsProvider = FutureProvider.family.autoDispose<List<AIInsight>, String>((ref, query) async {
  if (query.isEmpty) return [];
  
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.get(
      '/insights/search?query=${Uri.encodeComponent(query)}&limit=20',
    );
    
    if (response != null && response['results'] != null) {
      return (response['results'] as List)
          .map((insight) => AIInsight.fromJson(insight))
          .toList();
    }
    return [];
  } catch (e) {
    print('Error searching insights: $e');
    rethrow;
  }
});


final trendingInsightsProvider = FutureProvider.autoDispose<List<TrendingInsight>?>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.get('/insights/trending?limit=10');
    if (response != null && response['trending'] != null) {
      return (response['trending'] as List)
          .map((insight) => TrendingInsight.fromJson(insight))
          .toList();
    }
    return null;
  } catch (e) {
    print('Error fetching trending insights: $e');
    rethrow;
  }
});


// ==================== Personalization Provider ====================

class PersonalizationNotifier extends StateNotifier<void> {
  final ApiService apiService;
  final Ref ref;

  PersonalizationNotifier(this.apiService, this.ref) : super(null);

  Future<bool> triggerPersonalization() async {
    try {
      final response = await apiService.post('/insights/personalize');
      
      if (response != null && response['success'] == true) {
        // Refresh personalized insights
        ref.invalidate(personalizedInsightProvider);
        return true;
      }
      return false;
    } catch (e) {
      print('Error triggering personalization: $e');
      return false;
    }
  }
}

final personalizationProvider = StateNotifierProvider<PersonalizationNotifier, void>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PersonalizationNotifier(apiService, ref);
});


// ==================== Quality Metrics Provider ====================

final qualityMetricsProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.get('/insights/quality-metrics?days=7');
    return response as Map<String, dynamic>?;
  } catch (e) {
    print('Error fetching quality metrics: $e');
    rethrow;
  }
});


// ==================== Generation Logs Provider ====================

final generationLogsProvider = FutureProvider.autoDispose<List<GenerationLog>?>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.get('/insights/generation-logs?limit=50');
    if (response != null && response['logs'] != null) {
      return (response['logs'] as List)
          .map((log) => GenerationLog.fromJson(log))
          .toList();
    }
    return null;
  } catch (e) {
    print('Error fetching generation logs: $e');
    rethrow;
  }
});


// ==================== Model Classes ====================

class AIInsight {
  final String id;
  final String date;
  final String zodiacSign;
  final String title;
  final String shortSummary;
  final String fullContent;
  final String? mood;
  final double? confidenceScore;
  final Map<String, dynamic>? sections;
  final Map<String, dynamic>? astrologicalData;
  final int? viewCount;

  AIInsight({
    required this.id,
    required this.date,
    required this.zodiacSign,
    required this.title,
    required this.shortSummary,
    required this.fullContent,
    this.mood,
    this.confidenceScore,
    this.sections,
    this.astrologicalData,
    this.viewCount,
  });

  factory AIInsight.fromJson(Map<String, dynamic> json) => AIInsight(
    id: json['id'] as String,
    date: json['date'] as String,
    zodiacSign: json['zodiac_sign'] as String,
    title: json['title'] as String,
    shortSummary: json['short_summary'] as String,
    fullContent: json['full_content'] as String,
    mood: json['mood'] as String?,
    confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
    sections: json['sections'] as Map<String, dynamic>?,
    astrologicalData: json['astrological_data'] as Map<String, dynamic>?,
    viewCount: json['view_count'] as int?,
  );
}


class PersonalizedAIInsight {
  final String id;
  final String baseInsightId;
  final String personalizedTitle;
  final String personalizedContent;
  final Map<String, dynamic>? sections;
  final String? scheduledDeliveryTime;
  final String? deliveredAt;
  final int? viewCount;
  final String? userHistoryContext;

  PersonalizedAIInsight({
    required this.id,
    required this.baseInsightId,
    required this.personalizedTitle,
    required this.personalizedContent,
    this.sections,
    this.scheduledDeliveryTime,
    this.deliveredAt,
    this.viewCount,
    this.userHistoryContext,
  });

  factory PersonalizedAIInsight.fromJson(Map<String, dynamic> json) =>
      PersonalizedAIInsight(
        id: json['id'] as String,
        baseInsightId: json['base_insight_id'] as String,
        personalizedTitle: json['personalized_title'] as String,
        personalizedContent: json['personalized_content'] as String,
        sections: json['sections'] as Map<String, dynamic>?,
        scheduledDeliveryTime: json['scheduled_delivery_time'] as String?,
        deliveredAt: json['delivered_at'] as String?,
        viewCount: json['view_count'] as int?,
        userHistoryContext: json['user_history_context'] as String?,
      );
}


class InsightHistoryItem {
  final String id;
  final String title;
  final String zodiacSign;
  final String? viewedAt;
  final int? timeSpentSeconds;
  final int? rating;
  final bool? isFavorite;

  InsightHistoryItem({
    required this.id,
    required this.title,
    required this.zodiacSign,
    this.viewedAt,
    this.timeSpentSeconds,
    this.rating,
    this.isFavorite,
  });

  factory InsightHistoryItem.fromJson(Map<String, dynamic> json) =>
      InsightHistoryItem(
        id: json['id'] as String,
        title: json['title'] as String,
        zodiacSign: json['zodiac_sign'] as String,
        viewedAt: json['viewed_at'] as String?,
        timeSpentSeconds: json['time_spent_seconds'] as int?,
        rating: json['rating'] as int?,
        isFavorite: json['is_favorite'] as bool?,
      );
}


class TrendingInsight {
  final String id;
  final String title;
  final String zodiacSign;
  final int? viewCount;
  final int? engagementScore;

  TrendingInsight({
    required this.id,
    required this.title,
    required this.zodiacSign,
    this.viewCount,
    this.engagementScore,
  });

  factory TrendingInsight.fromJson(Map<String, dynamic> json) =>
      TrendingInsight(
        id: json['id'] as String,
        title: json['title'] as String,
        zodiacSign: json['zodiac_sign'] as String,
        viewCount: json['view_count'] as int?,
        engagementScore: json['engagement_score'] as int?,
      );
}


class GenerationLog {
  final String id;
  final String generationDate;
  final String aiModel;
  final double? generationTimeSeconds;
  final double? confidenceScore;
  final String status;
  final int? totalGenerated;

  GenerationLog({
    required this.id,
    required this.generationDate,
    required this.aiModel,
    this.generationTimeSeconds,
    this.confidenceScore,
    required this.status,
    this.totalGenerated,
  });

  factory GenerationLog.fromJson(Map<String, dynamic> json) => GenerationLog(
    id: json['id'] as String,
    generationDate: json['generation_date'] as String,
    aiModel: json['ai_model'] as String,
    generationTimeSeconds: (json['generation_time_seconds'] as num?)?.toDouble(),
    confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
    status: json['status'] as String,
    totalGenerated: json['total_generated'] as int?,
  );
}
