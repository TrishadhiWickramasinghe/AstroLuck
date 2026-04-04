class LuckyNumbers {
  final List<int> primaryNumbers;
  final List<int>? secondaryNumbers;
  final List<int> luckyDigits;
  final int energyLevel;
  final String energyStatus;
  final String luckyColor;
  final String luckyColorHex;
  final String zodiacInfluence;
  final DateTime generatedDate;
  final int lifePathNumber;
  final int destinyNumber;
  final int dailyLuckyNumber;
  final int luckyHour;
  final String moonPhase;
  final String planetaryDay;
  final String fortuneMessage;

  LuckyNumbers({
    required this.primaryNumbers,
    this.secondaryNumbers,
    required this.luckyDigits,
    required this.energyLevel,
    required this.energyStatus,
    required this.luckyColor,
    required this.luckyColorHex,
    required this.zodiacInfluence,
    required this.generatedDate,
    required this.lifePathNumber,
    required this.destinyNumber,
    required this.dailyLuckyNumber,
    required this.luckyHour,
    required this.moonPhase,
    required this.planetaryDay,
    required this.fortuneMessage,
  });

  factory LuckyNumbers.fromJson(Map<String, dynamic> json) {
    return LuckyNumbers(
      primaryNumbers: List<int>.from(json['primaryNumbers'] as List),
      secondaryNumbers: json['secondaryNumbers'] != null
          ? List<int>.from(json['secondaryNumbers'] as List)
          : null,
      luckyDigits: List<int>.from(json['luckyDigits'] as List),
      energyLevel: json['energyLevel'] as int,
      energyStatus: json['energyStatus'] as String? ?? '⚡ Unknown',
      luckyColor: json['luckyColor'] as String,
      luckyColorHex: json['luckyColorHex'] as String? ?? '#D4AF37',
      zodiacInfluence: json['zodiacInfluence'] as String,
      generatedDate: DateTime.parse(json['generatedDate'] as String),
      lifePathNumber: json['lifePathNumber'] as int? ?? 0,
      destinyNumber: json['destinyNumber'] as int? ?? 0,
      dailyLuckyNumber: json['dailyLuckyNumber'] as int? ?? 0,
      luckyHour: json['luckyHour'] as int? ?? 0,
      moonPhase: json['moonPhase'] as String? ?? 'Unknown',
      planetaryDay: json['planetaryDay'] as String? ?? 'Unknown',
      fortuneMessage: json['fortuneMessage'] as String? ?? 'May fortune favor you!',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryNumbers': primaryNumbers,
      'secondaryNumbers': secondaryNumbers,
      'luckyDigits': luckyDigits,
      'energyLevel': energyLevel,
      'energyStatus': energyStatus,
      'luckyColor': luckyColor,
      'luckyColorHex': luckyColorHex,
      'zodiacInfluence': zodiacInfluence,
      'generatedDate': generatedDate.toIso8601String(),
      'lifePathNumber': lifePathNumber,
      'destinyNumber': destinyNumber,
      'dailyLuckyNumber': dailyLuckyNumber,
      'luckyHour': luckyHour,
      'moonPhase': moonPhase,
      'planetaryDay': planetaryDay,
      'fortuneMessage': fortuneMessage,
    };
  }
}
