"""AI Daily Insights Model - Core data models for insights"""

class AIInsightModel {
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

  AIInsightModel({
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

  factory AIInsightModel.fromJson(Map<String, dynamic> json) => AIInsightModel(
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'zodiac_sign': zodiacSign,
    'title': title,
    'short_summary': shortSummary,
    'full_content': fullContent,
    if (mood != null) 'mood': mood,
    if (confidenceScore != null) 'confidence_score': confidenceScore,
    if (sections != null) 'sections': sections,
    if (astrologicalData != null) 'astrological_data': astrologicalData,
    if (viewCount != null) 'view_count': viewCount,
  };
}


class PersonalizedInsightModel {
  final String id;
  final String baseInsightId;
  final String personalizedTitle;
  final String personalizedContent;
  final Map<String, dynamic>? sections;
  final String? scheduledDeliveryTime;
  final String? deliveredAt;
  final int? viewCount;
  final String? userHistoryContext;

  PersonalizedInsightModel({
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

  factory PersonalizedInsightModel.fromJson(Map<String, dynamic> json) =>
      PersonalizedInsightModel(
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'base_insight_id': baseInsightId,
    'personalized_title': personalizedTitle,
    'personalized_content': personalizedContent,
    if (sections != null) 'sections': sections,
    if (scheduledDeliveryTime != null)
      'scheduled_delivery_time': scheduledDeliveryTime,
    if (deliveredAt != null) 'delivered_at': deliveredAt,
    if (viewCount != null) 'view_count': viewCount,
    if (userHistoryContext != null) 'user_history_context': userHistoryContext,
  };
}


class InsightHistoryModel {
  final String id;
  final String title;
  final String zodiacSign;
  final String? viewedAt;
  final int? timeSpentSeconds;
  final int? rating;
  final bool? isFavorite;

  InsightHistoryModel({
    required this.id,
    required this.title,
    required this.zodiacSign,
    this.viewedAt,
    this.timeSpentSeconds,
    this.rating,
    this.isFavorite,
  });

  factory InsightHistoryModel.fromJson(Map<String, dynamic> json) =>
      InsightHistoryModel(
        id: json['id'] as String,
        title: json['title'] as String,
        zodiacSign: json['zodiac_sign'] as String,
        viewedAt: json['viewed_at'] as String?,
        timeSpentSeconds: json['time_spent_seconds'] as int?,
        rating: json['rating'] as int?,
        isFavorite: json['is_favorite'] as bool?,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'zodiac_sign': zodiacSign,
    if (viewedAt != null) 'viewed_at': viewedAt,
    if (timeSpentSeconds != null) 'time_spent_seconds': timeSpentSeconds,
    if (rating != null) 'rating': rating,
    if (isFavorite != null) 'is_favorite': isFavorite,
  };
}


class TrendingInsightModel {
  final String id;
  final String title;
  final String zodiacSign;
  final int? viewCount;
  final int? engagementScore;

  TrendingInsightModel({
    required this.id,
    required this.title,
    required this.zodiacSign,
    this.viewCount,
    this.engagementScore,
  });

  factory TrendingInsightModel.fromJson(Map<String, dynamic> json) =>
      TrendingInsightModel(
        id: json['id'] as String,
        title: json['title'] as String,
        zodiacSign: json['zodiac_sign'] as String,
        viewCount: json['view_count'] as int?,
        engagementScore: json['engagement_score'] as int?,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'zodiac_sign': zodiacSign,
    if (viewCount != null) 'view_count': viewCount,
    if (engagementScore != null) 'engagement_score': engagementScore,
  };
}


class GenerationLogModel {
  final String id;
  final String generationDate;
  final String aiModel;
  final double? generationTimeSeconds;
  final double? confidenceScore;
  final String status;
  final int? totalGenerated;

  GenerationLogModel({
    required this.id,
    required this.generationDate,
    required this.aiModel,
    this.generationTimeSeconds,
    this.confidenceScore,
    required this.status,
    this.totalGenerated,
  });

  factory GenerationLogModel.fromJson(Map<String, dynamic> json) =>
      GenerationLogModel(
        id: json['id'] as String,
        generationDate: json['generation_date'] as String,
        aiModel: json['ai_model'] as String,
        generationTimeSeconds:
            (json['generation_time_seconds'] as num?)?.toDouble(),
        confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
        status: json['status'] as String,
        totalGenerated: json['total_generated'] as int?,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'generation_date': generationDate,
    'ai_model': aiModel,
    if (generationTimeSeconds != null)
      'generation_time_seconds': generationTimeSeconds,
    if (confidenceScore != null) 'confidence_score': confidenceScore,
    'status': status,
    if (totalGenerated != null) 'total_generated': totalGenerated,
  };
}


// Convenience type alias for backward compatibility
typedef AIInsight = AIInsightModel;
typedef PersonalizedAIInsight = PersonalizedInsightModel;
typedef InsightHistoryItem = InsightHistoryModel;
typedef TrendingInsight = TrendingInsightModel;
typedef GenerationLog = GenerationLogModel;
