import '../models/user_model.dart';
import '../models/lucky_number_model.dart';
import 'dart:math';

class LuckyNumberService {
  static LuckyNumbers generateDailyLuckyNumbers(UserProfile user) {
    final random = Random(DateTime.now().day);

    final primaryNumbers = [
      random.nextInt(50) + 1,
      random.nextInt(50) + 1,
      random.nextInt(50) + 1,
    ];

    final secondaryNumbers = [
      random.nextInt(99) + 1,
      random.nextInt(99) + 1,
    ];

    final luckyDigits = [
      random.nextInt(10),
      random.nextInt(10),
    ];

    final colors = ['Gold', 'Purple', 'Blue', 'Red', 'Green'];
    final luckyColor = colors[random.nextInt(colors.length)];

    final energyLevel = random.nextInt(100) + 1;

    return LuckyNumbers(
      primaryNumbers: primaryNumbers,
      secondaryNumbers: secondaryNumbers,
      luckyDigits: luckyDigits,
      energyLevel: energyLevel,
      luckyColor: luckyColor,
      zodiacInfluence: user.zodiacSign,
      generatedDate: DateTime.now(),
    );
  }
}
