"""AI Daily Insights Models - Data models for insights"""

class UserInsightPreference {
  final String id;
  final bool? insightsEnabled;
  final String? deliveryTime;
  final String? deliveryTimezone;
  final String? deliveryFrequency;
  final PreferenceChannels? channels;
  final ContentPreferences? contentPreferences;
  final String? writingStyle;
  final String? contentLength;
  final QuietHours? quietHours;
  final bool? autoSaveFavorites;
  final bool? enableWeeklyDigest;

  UserInsightPreference({
    required this.id,
    this.insightsEnabled,
    this.deliveryTime,
    this.deliveryTimezone,
    this.deliveryFrequency,
    this.channels,
    this.contentPreferences,
    this.writingStyle,
    this.contentLength,
    this.quietHours,
    this.autoSaveFavorites,
    this.enableWeeklyDigest,
  });

  factory UserInsightPreference.fromJson(Map<String, dynamic> json) {
    return UserInsightPreference(
      id: json['id'] as String,
      insightsEnabled: json['insights_enabled'] as bool?,
      deliveryTime: json['delivery_time'] as String?,
      deliveryTimezone: json['delivery_timezone'] as String?,
      deliveryFrequency: json['delivery_frequency'] as String?,
      channels: json['channels'] != null
          ? PreferenceChannels.fromJson(json['channels'])
          : null,
      contentPreferences: json['content_preferences'] != null
          ? ContentPreferences.fromJson(json['content_preferences'])
          : null,
      writingStyle: json['writing_style'] as String?,
      contentLength: json['content_length'] as String?,
      quietHours: json['quiet_hours'] != null
          ? QuietHours.fromJson(json['quiet_hours'])
          : null,
      autoSaveFavorites: json['auto_save_favorites'] as bool?,
      enableWeeklyDigest: json['enable_weekly_digest'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (insightsEnabled != null) 'insights_enabled': insightsEnabled,
    if (deliveryTime != null) 'delivery_time': deliveryTime,
    if (deliveryTimezone != null) 'delivery_timezone': deliveryTimezone,
    if (deliveryFrequency != null) 'delivery_frequency': deliveryFrequency,
    if (channels != null) 'channels': channels?.toJson(),
    if (contentPreferences != null)
      'content_preferences': contentPreferences?.toJson(),
    if (writingStyle != null) 'writing_style': writingStyle,
    if (contentLength != null) 'content_length': contentLength,
    if (quietHours != null) 'quiet_hours': quietHours?.toJson(),
    if (autoSaveFavorites != null) 'auto_save_favorites': autoSaveFavorites,
    if (enableWeeklyDigest != null) 'enable_weekly_digest': enableWeeklyDigest,
  };
}


class PreferenceChannels {
  final bool? email;
  final bool? push;
  final bool? whatsapp;

  PreferenceChannels({
    this.email,
    this.push,
    this.whatsapp,
  });

  factory PreferenceChannels.fromJson(Map<String, dynamic> json) {
    return PreferenceChannels(
      email: json['email'] as bool?,
      push: json['push'] as bool?,
      whatsapp: json['whatsapp'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (email != null) 'email': email,
    if (push != null) 'push': push,
    if (whatsapp != null) 'whatsapp': whatsapp,
  };
}


class ContentPreferences {
  final List<String>? insightTypes;
  final String? mood;
  final double? personalizationLevel;
  final bool? includeBirthChart;
  final bool? includeTransitData;
  final bool? includeNumerology;
  final bool? includeTarot;

  ContentPreferences({
    this.insightTypes,
    this.mood,
    this.personalizationLevel,
    this.includeBirthChart,
    this.includeTransitData,
    this.includeNumerology,
    this.includeTarot,
  });

  factory ContentPreferences.fromJson(Map<String, dynamic> json) {
    return ContentPreferences(
      insightTypes: List<String>.from(json['insight_types'] as List? ?? []),
      mood: json['mood'] as String?,
      personalizationLevel: (json['personalization_level'] as num?)?.toDouble(),
      includeBirthChart: json['include_birth_chart'] as bool?,
      includeTransitData: json['include_transit_data'] as bool?,
      includeNumerology: json['include_numerology'] as bool?,
      includeTarot: json['include_tarot'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (insightTypes != null) 'insight_types': insightTypes,
    if (mood != null) 'mood': mood,
    if (personalizationLevel != null)
      'personalization_level': personalizationLevel,
    if (includeBirthChart != null) 'include_birth_chart': includeBirthChart,
    if (includeTransitData != null) 'include_transit_data': includeTransitData,
    if (includeNumerology != null) 'include_numerology': includeNumerology,
    if (includeTarot != null) 'include_tarot': includeTarot,
  };
}


class QuietHours {
  final bool? enabled;
  final String? start;
  final String? end;

  QuietHours({
    this.enabled,
    this.start,
    this.end,
  });

  factory QuietHours.fromJson(Map<String, dynamic> json) {
    return QuietHours(
      enabled: json['enabled'] as bool?,
      start: json['start'] as String?,
      end: json['end'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (enabled != null) 'enabled': enabled,
    if (start != null) 'start': start,
    if (end != null) 'end': end,
  };
}


class AstrologicalData {
  final String? moonPhase;
  final bool? mercuryRetrograde;
  final Map<String, dynamic>? planetaryPositions;
  final List<String>? venusAspects;
  final List<String>? marsInfluences;
  final List<String>? dominantElements;

  AstrologicalData({
    this.moonPhase,
    this.mercuryRetrograde,
    this.planetaryPositions,
    this.venusAspects,
    this.marsInfluences,
    this.dominantElements,
  });

  factory AstrologicalData.fromJson(Map<String, dynamic> json) {
    return AstrologicalData(
      moonPhase: json['moon_phase'] as String?,
      mercuryRetrograde: json['mercury_retrograde'] as bool?,
      planetaryPositions: json['planetary_positions'] as Map<String, dynamic>?,
      venusAspects: List<String>.from(json['venus_aspects'] as List? ?? []),
      marsInfluences: List<String>.from(json['mars_influences'] as List? ?? []),
      dominantElements: List<String>.from(json['dominant_elements'] as List? ?? []),
    );
  }
}


class InsightSections {
  final Map<String, dynamic>? luckyTimes;
  final List<String>? luckyColors;
  final List<int>? luckyNumbers;
  final String? elementFocus;
  final String? powerAffirmation;
  final String? tarotCard;
  final Map<String, dynamic>? numerology;
  final String? careerFocus;
  final String? romanceInsight;
  final String? healthTip;
  final String? financialGuidance;

  InsightSections({
    this.luckyTimes,
    this.luckyColors,
    this.luckyNumbers,
    this.elementFocus,
    this.powerAffirmation,
    this.tarotCard,
    this.numerology,
    this.careerFocus,
    this.romanceInsight,
    this.healthTip,
    this.financialGuidance,
  });

  factory InsightSections.fromJson(Map<String, dynamic> json) {
    return InsightSections(
      luckyTimes: json['lucky_times'] as Map<String, dynamic>?,
      luckyColors: List<String>.from(json['lucky_colors'] as List? ?? []),
      luckyNumbers: List<int>.from(json['lucky_numbers'] as List? ?? []),
      elementFocus: json['element_focus'] as String?,
      powerAffirmation: json['power_affirmation'] as String?,
      tarotCard: json['tarot_card'] as String?,
      numerology: json['numerology'] as Map<String, dynamic>?,
      careerFocus: json['career_focus'] as String?,
      romanceInsight: json['romance_insight'] as String?,
      healthTip: json['health_tip'] as String?,
      financialGuidance: json['financial_guidance'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (luckyTimes != null) 'lucky_times': luckyTimes,
    if (luckyColors != null) 'lucky_colors': luckyColors,
    if (luckyNumbers != null) 'lucky_numbers': luckyNumbers,
    if (elementFocus != null) 'element_focus': elementFocus,
    if (powerAffirmation != null) 'power_affirmation': powerAffirmation,
    if (tarotCard != null) 'tarot_card': tarotCard,
    if (numerology != null) 'numerology': numerology,
    if (careerFocus != null) 'career_focus': careerFocus,
    if (romanceInsight != null) 'romance_insight': romanceInsight,
    if (healthTip != null) 'health_tip': healthTip,
    if (financialGuidance != null) 'financial_guidance': financialGuidance,
  };
}


class InsightEngagement {
  final int? viewCount;
  final int? savedCount;
  final int? sharedCount;
  final String? engagementRate;

  InsightEngagement({
    this.viewCount,
    this.savedCount,
    this.sharedCount,
    this.engagementRate,
  });

  factory InsightEngagement.fromJson(Map<String, dynamic> json) {
    return InsightEngagement(
      viewCount: json['total_views'] as int?,
      savedCount: json['saved_count'] as int?,
      sharedCount: json['shared_count'] as int?,
      engagementRate: json['engagement_rate'] as String?,
    );
  }
}


class InsightFeedback {
  final String id;
  final String insightId;
  final int rating;
  final String? comment;
  final List<String>? tags;
  final String? createdAt;

  InsightFeedback({
    required this.id,
    required this.insightId,
    required this.rating,
    this.comment,
    this.tags,
    this.createdAt,
  });

  factory InsightFeedback.fromJson(Map<String, dynamic> json) {
    return InsightFeedback(
      id: json['id'] as String,
      insightId: json['insight_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'insight_id': insightId,
    'rating': rating,
    if (comment != null) 'comment': comment,
    if (tags != null) 'tags': tags,
    if (createdAt != null) 'created_at': createdAt,
  };
}


class InsightQualityMetrics {
  final int? periodDays;
  final int? totalGenerations;
  final int? successful;
  final int? failed;
  final String? successRate;
  final String? averageConfidenceScore;
  final String? averageDiversityScore;
  final double? averageGenerationTimeSeconds;

  InsightQualityMetrics({
    this.periodDays,
    this.totalGenerations,
    this.successful,
    this.failed,
    this.successRate,
    this.averageConfidenceScore,
    this.averageDiversityScore,
    this.averageGenerationTimeSeconds,
  });

  factory InsightQualityMetrics.fromJson(Map<String, dynamic> json) {
    return InsightQualityMetrics(
      periodDays: json['period_days'] as int?,
      totalGenerations: json['total_generations'] as int?,
      successful: json['successful'] as int?,
      failed: json['failed'] as int?,
      successRate: json['success_rate'] as String?,
      averageConfidenceScore: json['average_confidence_score'] as String?,
      averageDiversityScore: json['average_diversity_score'] as String?,
      averageGenerationTimeSeconds:
          (json['average_generation_time_seconds'] as num?)?.toDouble(),
    );
  }
}
