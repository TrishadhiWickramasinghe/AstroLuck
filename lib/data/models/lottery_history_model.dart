class LotteryEntry {
  final String id;
  final String lotteryType; // '6/49', '4-Digit', etc.
  final List<int> numbers;
  final int? bonusNumber; // For Powerball, Mega Millions, etc.
  final DateTime drawDate;
  final DateTime addedDate;
  final bool didWin;
  final String? prizeAmount;
  final String? notes;

  LotteryEntry({
    required this.id,
    required this.lotteryType,
    required this.numbers,
    this.bonusNumber,
    required this.drawDate,
    required this.addedDate,
    required this.didWin,
    this.prizeAmount,
    this.notes,
  });

  factory LotteryEntry.fromJson(Map<String, dynamic> json) {
    return LotteryEntry(
      id: json['id'] as String,
      lotteryType: json['lotteryType'] as String,
      numbers: List<int>.from(json['numbers'] as List),
      bonusNumber: json['bonusNumber'] as int?,
      drawDate: DateTime.parse(json['drawDate'] as String),
      addedDate: DateTime.parse(json['addedDate'] as String),
      didWin: json['didWin'] as bool,
      prizeAmount: json['prizeAmount'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lotteryType': lotteryType,
      'numbers': numbers,
      'bonusNumber': bonusNumber,
      'drawDate': drawDate.toIso8601String(),
      'addedDate': addedDate.toIso8601String(),
      'didWin': didWin,
      'prizeAmount': prizeAmount,
      'notes': notes,
    };
  }
}

class PatternAnalysis {
  final List<int> frequentDigits;
  final List<int> rarelUsedDigits;
  final Map<int, int> digitFrequency;
  final List<int> avoidThisWeek;
  final List<int> recommendThisWeek;
  final String analysisMessage;
  final DateTime analysisDate;

  PatternAnalysis({
    required this.frequentDigits,
    required this.rarelUsedDigits,
    required this.digitFrequency,
    required this.avoidThisWeek,
    required this.recommendThisWeek,
    required this.analysisMessage,
    required this.analysisDate,
  });

  factory PatternAnalysis.fromJson(Map<String, dynamic> json) {
    return PatternAnalysis(
      frequentDigits: List<int>.from(json['frequentDigits'] as List),
      rarelUsedDigits: List<int>.from(json['rarelUsedDigits'] as List),
      digitFrequency: Map<String, int>.from(json['digitFrequency'] as Map).cast<String, int>().map(
        (key, value) => MapEntry(int.parse(key), value),
      ),
      avoidThisWeek: List<int>.from(json['avoidThisWeek'] as List),
      recommendThisWeek: List<int>.from(json['recommendThisWeek'] as List),
      analysisMessage: json['analysisMessage'] as String,
      analysisDate: DateTime.parse(json['analysisDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frequentDigits': frequentDigits,
      'rarelUsedDigits': rarelUsedDigits,
      'digitFrequency': digitFrequency.map((key, value) => MapEntry(key.toString(), value)),
      'avoidThisWeek': avoidThisWeek,
      'recommendThisWeek': recommendThisWeek,
      'analysisMessage': analysisMessage,
      'analysisDate': analysisDate.toIso8601String(),
    };
  }
}
