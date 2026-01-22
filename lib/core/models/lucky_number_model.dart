class LuckyNumbers {
  final List<int> primaryNumbers;
  final List<int>? secondaryNumbers;
  final List<int> luckyDigits;
  final int energyLevel;
  final String luckyColor;
  final String zodiacInfluence;
  final DateTime generatedDate;
  final List<dynamic> numberEnergy;

  LuckyNumbers({
    required this.primaryNumbers,
    this.secondaryNumbers,
    required this.luckyDigits,
    required this.energyLevel,
    required this.luckyColor,
    required this.zodiacInfluence,
    required this.generatedDate,
    this.numberEnergy = const [],
  });

  factory LuckyNumbers.fromJson(Map<String, dynamic> json) {
    return LuckyNumbers(
      primaryNumbers: List<int>.from(json['primaryNumbers'] as List),
      secondaryNumbers: json['secondaryNumbers'] != null
          ? List<int>.from(json['secondaryNumbers'] as List)
          : null,
      luckyDigits: List<int>.from(json['luckyDigits'] as List),
      energyLevel: json['energyLevel'] as int,
      luckyColor: json['luckyColor'] as String,
      zodiacInfluence: json['zodiacInfluence'] as String,
      generatedDate: DateTime.parse(json['generatedDate'] as String),
      numberEnergy: json['numberEnergy'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryNumbers': primaryNumbers,
      'secondaryNumbers': secondaryNumbers,
      'luckyDigits': luckyDigits,
      'energyLevel': energyLevel,
      'luckyColor': luckyColor,
      'zodiacInfluence': zodiacInfluence,
      'generatedDate': generatedDate.toIso8601String(),
      'numberEnergy': numberEnergy,
    };
  }
}
