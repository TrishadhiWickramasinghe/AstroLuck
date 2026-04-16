"""
Statistics Models for Flutter
Data models for lottery statistics dashboard.
"""

import 'package:freezed_annotation/freezed_annotation.dart';

part 'statistics_models.freezed.dart';
part 'statistics_models.g.dart';

// ========================
// Hot/Cold Numbers
// ========================

@freezed
class HotColdNumber with _$HotColdNumber {
  const factory HotColdNumber({
    required int number,
    required String category, // hot, cold, warm, neutral
    required double frequencyScore,
    required int appearanceCount,
    int? daysSinceLast,
    String? trend,
  }) = _HotColdNumber;

  factory HotColdNumber.fromJson(Map<String, dynamic> json) =>
      _$HotColdNumberFromJson(json);
}

@freezed
class HotColdOverview with _$HotColdOverview {
  const factory HotColdOverview({
    required List<HotColdNumber> hotNumbers,
    required List<HotColdNumber> coldNumbers,
    required List<HotColdNumber> warmNumbers,
    required String lotteryType,
    required DateTime analysisDate,
  }) = _HotColdOverview;

  factory HotColdOverview.fromJson(Map<String, dynamic> json) =>
      _$HotColdOverviewFromJson(json);
}

@freezed
class NumberAnalysisDetail with _$NumberAnalysisDetail {
  const factory NumberAnalysisDetail({
    required int number,
    required int totalAppearances,
    required double heatScore,
    required double coldScore,
    required double meanGapDays,
    required int? maxGapDays,
    required int recent30d,
    required int recent90d,
    required bool recommended,
  }) = _NumberAnalysisDetail;

  factory NumberAnalysisDetail.fromJson(Map<String, dynamic> json) =>
      _$NumberAnalysisDetailFromJson(json);
}

// ========================
// Trends
// ========================

@freezed
class TrendNumber with _$TrendNumber {
  const factory TrendNumber({
    required int number,
    required String direction, // increasing, decreasing, stable
    required double strength, // 0-1
    required double changePercentage,
    required double confidence,
    double? predictedNextValue,
  }) = _TrendNumber;

  factory TrendNumber.fromJson(Map<String, dynamic> json) =>
      _$TrendNumberFromJson(json);
}

@freezed
class TrendsOverview with _$TrendsOverview {
  const factory TrendsOverview({
    required List<TrendNumber> trendingUp,
    required List<TrendNumber> trendingDown,
    required DateTime analysisDate,
    required int periodDays,
  }) = _TrendsOverview;

  factory TrendsOverview.fromJson(Map<String, dynamic> json) =>
      _$TrendsOverviewFromJson(json);
}

// ========================
// Winning Patterns
// ========================

@freezed
class WinningPatternData with _$WinningPatternData {
  const factory WinningPatternData({
    required String id,
    required String name,
    required String type, // consecutive, arithmetic_sequence, symmetry, etc.
    required double frequency, // % of drawings
    double? hitRate,
    required double confidence,
    required int occurrences,
  }) = _WinningPatternData;

  factory WinningPatternData.fromJson(Map<String, dynamic> json) =>
      _$WinningPatternDataFromJson(json);
}

// ========================
// Personal Statistics
// ========================

@freezed
class PersonalStatistics with _$PersonalStatistics {
  const factory PersonalStatistics({
    required int totalTickets,
    required double totalSpent,
    required double totalWinnings,
    required double winRate, // %
    required double roi, // Return on investment %
    required double largestWin,
    required String playFrequency, // daily, weekly, monthly
    required int daysPlaying,
  }) = _PersonalStatistics;

  factory PersonalStatistics.fromJson(Map<String, dynamic> json) =>
      _$PersonalStatisticsFromJson(json);
}

// ========================
// Engagement
// ========================

@freezed
class EngagementStats with _$EngagementStats {
  const factory EngagementStats({
    required int totalViews,
    required int uniqueUsers,
    required double avgTimeSpent, // seconds
    required double purchaseRate, // %
  }) = _EngagementStats;

  factory EngagementStats.fromJson(Map<String, dynamic> json) =>
      _$EngagementStatsFromJson(json);
}

// ========================
// Dashboard Preferences
// ========================

@freezed
class DashboardPreferences with _$DashboardPreferences {
  const factory DashboardPreferences({
    @Default(true) bool showHotCold,
    @Default(true) bool showTrends,
    @Default(true) bool showPatterns,
    @Default(true) bool showPersonalStats,
    @Default('30_days') String analysisPeriod,
    @Default(false) bool darkMode,
    @Default(true) bool notifyHotNumbers,
    @Default(true) bool notifyNewPatterns,
  }) = _DashboardPreferences;

  factory DashboardPreferences.fromJson(Map<String, dynamic> json) =>
      _$DashboardPreferencesFromJson(json);
}

// ========================
// Dashboard Summary
// ========================

@freezed
class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    required List<HotColdNumber> hotNumbers,
    required List<HotColdNumber> coldNumbers,
    required List<TrendNumber> trending,
    required List<WinningPatternData> patterns,
    PersonalStatistics? userStats,
    required DateTime generatedAt,
  }) = _DashboardSummary;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) =>
      _$DashboardSummaryFromJson(json);
}

// ========================
// Main Dashboard Data
// ========================

@freezed
class MainDashboardData with _$MainDashboardData {
  const factory MainDashboardData({
    required DashboardSummary summary,
    required PersonalStatistics personal,
    required EngagementStats engagement,
  }) = _MainDashboardData;

  factory MainDashboardData.fromJson(Map<String, dynamic> json) =>
      _$MainDashboardDataFromJson(json);
}

// ========================
// Chart Data
// ========================

@freezed
class PieChartSegment with _$PieChartSegment {
  const factory PieChartSegment({
    required String label,
    required double value,
    required int color,
  }) = _PieChartSegment;

  factory PieChartSegment.fromJson(Map<String, dynamic> json) =>
      _$PieChartSegmentFromJson(json);
}

@freezed
class BarChartEntry with _$BarChartEntry {
  const factory BarChartEntry({
    required String label,
    required double value,
    int? color,
  }) = _BarChartEntry;

  factory BarChartEntry.fromJson(Map<String, dynamic> json) =>
      _$BarChartEntryFromJson(json);
}

@freezed
class LineChartPoint with _$LineChartPoint {
  const factory LineChartPoint({
    required DateTime date,
    required double value,
  }) = _LineChartPoint;

  factory LineChartPoint.fromJson(Map<String, dynamic> json) =>
      _$LineChartPointFromJson(json);
}

// ========================
// Filter & Sort State
// ========================

@freezed
class StatisticsFilter with _$StatisticsFilter {
  const factory StatisticsFilter({
    @Default('powerball') String lotteryType,
    @Default('all') String hotColdFilter, // all, hot, cold, warm, neutral
    @Default('30_days') String analysisPeriod,
    @Default('frequency_score') String sortBy,
    @Default(false) bool descendingSort,
  }) = _StatisticsFilter;

  factory StatisticsFilter.fromJson(Map<String, dynamic> json) =>
      _$StatisticsFilterFromJson(json);
}
