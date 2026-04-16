"""
Statistics Dashboard Providers
Riverpod state management for lottery statistics and analytics.
"""

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/statistics_models.dart';

// HTTP Client
final dioProvider = Provider((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.astroluck.com/api/v1',
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
  ));
  return dio;
});

// ========================
// Dashboard Data Providers
// ========================

/// Get complete dashboard summary
final dashboardSummaryProvider = FutureProvider.family<DashboardSummary, String>((ref, lotteryType) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get(
      '/statistics/dashboard/summary',
      queryParameters: {'lottery_type': lotteryType},
    );
    return DashboardSummary.fromJson(response.data['data']);
  } catch (e) {
    throw Exception('Failed to fetch dashboard summary: $e');
  }
});

/// Get hot and cold numbers overview
final hotColdOverviewProvider = FutureProvider.family<HotColdOverview, String>((ref, lotteryType) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get(
      '/statistics/hot-cold/overview',
      queryParameters: {'lottery_type': lotteryType, 'limit': 15},
    );
    return HotColdOverview.fromJson(response.data['data']);
  } catch (e) {
    throw Exception('Failed to fetch hot/cold overview: $e');
  }
});

/// Get detailed analysis for specific number
final numberDetailProvider = FutureProvider.family<NumberAnalysisDetail, NumberDetailParams>((ref, params) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get(
      '/statistics/hot-cold/detail/${params.number}',
      queryParameters: {'lottery_type': params.lotteryType},
    );
    return NumberAnalysisDetail.fromJson(response.data['data']);
  } catch (e) {
    throw Exception('Failed to fetch number detail: $e');
  }
});

/// Get trends overview
final trendsOverviewProvider = FutureProvider.family<TrendsOverview, String>((ref, lotteryType) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get(
      '/statistics/trends/overview',
      queryParameters: {'lottery_type': lotteryType, 'limit': 15},
    );
    return TrendsOverview.fromJson(response.data['data']);
  } catch (e) {
    throw Exception('Failed to fetch trends: $e');
  }
});

/// Get top winning patterns
final topPatternsProvider = FutureProvider.family<List<WinningPatternData>, String>((ref, lotteryType) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get(
      '/statistics/patterns/top',
      queryParameters: {'lottery_type': lotteryType, 'limit': 10},
    );
    final data = response.data['data']['patterns'] as List;
    return data.map((p) => WinningPatternData.fromJson(p)).toList();
  } catch (e) {
    throw Exception('Failed to fetch patterns: $e');
  }
});

/// Get user's personal statistics
final personalStatisticsProvider = FutureProvider.family<PersonalStatistics, String>((ref, lotteryType) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get(
      '/statistics/personal/summary',
      queryParameters: {'lottery_type': lotteryType},
    );
    return PersonalStatistics.fromJson(response.data['data']);
  } catch (e) {
    throw Exception('Failed to fetch personal stats: $e');
  }
});

/// Get user's lucky numbers
final luckyNumbersProvider = FutureProvider.family<List<int>, String>((ref, lotteryType) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get(
      '/statistics/personal/lucky-numbers',
      queryParameters: {'lottery_type': lotteryType},
    );
    final numbers = response.data['data']['lucky_numbers'] as List;
    return numbers.cast<int>();
  } catch (e) {
    throw Exception('Failed to fetch lucky numbers: $e');
  }
});

/// Get engagement statistics
final engagementStatsProvider = FutureProvider.family<EngagementStats, String>((ref, lotteryType) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get(
      '/statistics/engagement/stats',
      queryParameters: {'lottery_type': lotteryType, 'days': 30},
    );
    return EngagementStats.fromJson(response.data['data']);
  } catch (e) {
    throw Exception('Failed to fetch engagement stats: $e');
  }
});

/// Get number recommendations
final numberRecommendationsProvider = FutureProvider.family<List<int>, String>((ref, lotteryType) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get(
      '/statistics/recommendations/numbers',
      queryParameters: {'lottery_type': lotteryType, 'count': 6},
    );
    final numbers = response.data['data']['recommended_numbers'] as List;
    return numbers.cast<int>();
  } catch (e) {
    throw Exception('Failed to fetch recommendations: $e');
  }
});

// ========================
// State Notifiers for Preferences
// ========================

/// StateNotifier for dashboard preferences
class PreferencesNotifier extends StateNotifier<DashboardPreferences> {
  final Dio dio;

  PreferencesNotifier(this.dio) : super(const DashboardPreferences());

  Future<void> loadPreferences(String lotteryType) async {
    try {
      final response = await dio.get(
        '/statistics/preferences',
        queryParameters: {'lottery_type': lotteryType},
      );
      final prefs = DashboardPreferences.fromJson(response.data['data']);
      state = prefs;
    } catch (e) {
      print('Error loading preferences: $e');
    }
  }

  Future<void> updatePreferences(String lotteryType, Map<String, dynamic> updates) async {
    try {
      await dio.put(
        '/statistics/preferences',
        queryParameters: {'lottery_type': lotteryType},
        data: updates,
      );
      
      // Update local state
      state = state.copyWith(
        showHotCold: updates['show_hot_cold'] ?? state.showHotCold,
        showTrends: updates['show_trends'] ?? state.showTrends,
        showPatterns: updates['show_patterns'] ?? state.showPatterns,
        darkMode: updates['dark_mode'] ?? state.darkMode,
      );
    } catch (e) {
      print('Error updating preferences: $e');
    }
  }

  void toggleDarkMode() {
    state = state.copyWith(darkMode: !state.darkMode);
  }

  void setAnalysisPeriod(String period) {
    state = state.copyWith(analysisPeriod: period);
  }
}

final preferencesProvider = StateNotifierProvider<PreferencesNotifier, DashboardPreferences>((ref) {
  final dio = ref.watch(dioProvider);
  return PreferencesNotifier(dio);
});

// ========================
// Engagement Tracking
// ========================

/// StateNotifier for logging engagement
class EngagementNotifier extends StateNotifier<bool> {
  final Dio dio;

  EngagementNotifier(this.dio) : super(false);

  Future<void> logView(String screen, int timeSpent, String lotteryType) async {
    try {
      await dio.post(
        '/statistics/engagement/view',
        queryParameters: {
          'screen': screen,
          'time_spent_seconds': timeSpent,
          'lottery_type': lotteryType,
        },
      );
      state = true; // Mark as logged
    } catch (e) {
      print('Error logging view: $e');
    }
  }

  Future<void> submitRecommendationFeedback(
    List<int> numbers,
    bool purchased,
    bool won,
  ) async {
    try {
      await dio.post(
        '/statistics/recommendations/feedback',
        queryParameters: {
          'recommended_numbers': numbers,
          'purchased': purchased,
          'won': won,
        },
      );
    } catch (e) {
      print('Error submitting feedback: $e');
    }
  }
}

final engagementNotifierProvider = StateNotifierProvider<EngagementNotifier, bool>((ref) {
  final dio = ref.watch(dioProvider);
  return EngagementNotifier(dio);
});

// ========================
// Search & Filtering
// ========================

final selectedLotteryTypeProvider = StateProvider<String>((ref) => 'powerball');

final hotColdFilterProvider = StateProvider<String>((ref) => 'all'); // all, hot, cold

final analysisPeriodProvider = StateProvider<String>((ref) => '30_days');

// ========================
// Chart Data Providers
// ========================

/// Prepare data for hot/cold chart
final hotColdChartDataProvider = FutureProvider.family<List<ChartEntry>, String>((ref, lotteryType) async {
  final overview = await ref.watch(hotColdOverviewProvider(lotteryType).future);
  
  final entries = <ChartEntry>[];
  
  // Add hot numbers
  for (final num in overview.hotNumbers) {
    entries.add(ChartEntry(
      label: num.number.toString(),
      value: num.frequencyScore,
      color: 0xFFFF6B6B, // Red for hot
    ));
  }
  
  return entries;
});

/// Prepare data for trends chart
final trendsChartDataProvider = FutureProvider.family<List<ChartEntry>, String>((ref, lotteryType) async {
  final trends = await ref.watch(trendsOverviewProvider(lotteryType).future);
  
  final entries = <ChartEntry>[];
  
  // Add trending up
  for (final trend in trends.trendingUp.take(5)) {
    entries.add(ChartEntry(
      label: trend.number.toString(),
      value: trend.strength * 100,
      color: 0xFF51CF66, // Green for up
    ));
  }
  
  return entries;
});

// ========================
// Combined Dashboard Provider
// ========================

/// Combined provider for main dashboard
final mainDashboardProvider = FutureProvider.family<MainDashboardData, String>((ref, lotteryType) async {
  final summary = await ref.watch(dashboardSummaryProvider(lotteryType).future);
  final personal = await ref.watch(personalStatisticsProvider(lotteryType).future);
  final engagement = await ref.watch(engagementStatsProvider(lotteryType).future);
  
  return MainDashboardData(
    summary: summary,
    personal: personal,
    engagement: engagement,
  );
});

// ========================
// Helper Models for Parameters
// ========================

class NumberDetailParams {
  final int number;
  final String lotteryType;
  
  NumberDetailParams({
    required this.number,
    required this.lotteryType,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NumberDetailParams &&
          runtimeType == other.runtimeType &&
          number == other.number &&
          lotteryType == other.lotteryType;

  @override
  int get hashCode => number.hashCode ^ lotteryType.hashCode;
}

class ChartEntry {
  final String label;
  final double value;
  final int color;
  
  ChartEntry({
    required this.label,
    required this.value,
    required this.color,
  });
}
