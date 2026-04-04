import 'dart:math';

class LotteryType {
  final String name;
  final int minRange;
  final int maxRange;
  final int numbersToGenerate;
  final int? bonusMaxRange;

  const LotteryType({
    required this.name,
    required this.minRange,
    required this.maxRange,
    required this.numbersToGenerate,
    this.bonusMaxRange,
  });
}

class LotteryUtils {
  // Predefined lottery types
  static const Map<String, LotteryType> lotteryTypes = {
    '6/49': LotteryType(
      name: '6/49',
      minRange: 1,
      maxRange: 49,
      numbersToGenerate: 6,
    ),
    '4-Digit': LotteryType(
      name: '4-Digit',
      minRange: 0,
      maxRange: 9999,
      numbersToGenerate: 1,
    ),
    'Powerball': LotteryType(
      name: 'Powerball',
      minRange: 1,
      maxRange: 69,
      numbersToGenerate: 5,
      bonusMaxRange: 26,
    ),
    'Mega Millions': LotteryType(
      name: 'Mega Millions',
      minRange: 1,
      maxRange: 70,
      numbersToGenerate: 5,
      bonusMaxRange: 25,
    ),
    '5/50': LotteryType(
      name: '5/50',
      minRange: 1,
      maxRange: 50,
      numbersToGenerate: 5,
    ),
  };

  /// Generate lottery numbers using numerology formula
  /// Formula: (Daily Lucky Number × Multiplier) % MaxRange
  /// If result < MinRange → add MinRange
  static List<int> generateLotteryNumbers(
    int dailyLuckyNumber,
    String lotteryTypeName,
  ) {
    final lottery = lotteryTypes[lotteryTypeName];
    if (lottery == null) {
      throw 'Unknown lottery type: $lotteryTypeName';
    }

    final multipliers = [3, 5, 7, 9, 11, 13];
    final numbers = <int>{};
    final range = lottery.maxRange - lottery.minRange + 1;

    int multiplierIndex = 0;
    while (numbers.length < lottery.numbersToGenerate && multiplierIndex < multipliers.length) {
      final multiplier = multipliers[multiplierIndex];
      int number = (dailyLuckyNumber * multiplier) % range;
      
      // Adjust to lottery range
      if (number < lottery.minRange) {
        number += lottery.minRange;
      } else {
        number += lottery.minRange - 1;
      }

      // Ensure within bounds
      number = number.clamp(lottery.minRange, lottery.maxRange);
      
      if (number >= lottery.minRange && number <= lottery.maxRange) {
        numbers.add(number);
      }
      
      multiplierIndex++;
    }

    return numbers.toList()..sort();
  }

  /// Generate bonus ball for lotteries like Powerball
  static int generateBonusNumber(int dailyLuckyNumber, LotteryType lottery) {
    if (lottery.bonusMaxRange == null) {
      throw 'This lottery type does not have bonus numbers';
    }
    
    final multiplier = 17;
    int bonus = (dailyLuckyNumber * multiplier) % lottery.bonusMaxRange!;
    
    if (bonus == 0) {
      bonus = lottery.bonusMaxRange!;
    }
    
    return bonus;
  }

  /// Get random element from a list for "risky number" (for fun variety)
  static int generateRiskyNumber(String lotteryTypeName) {
    final lottery = lotteryTypes[lotteryTypeName];
    if (lottery == null) {
      throw 'Unknown lottery type: $lotteryTypeName';
    }

    final random = Random(DateTime.now().millisecond);
    return random.nextInt(lottery.maxRange - lottery.minRange + 1) + lottery.minRange;
  }

  /// Get all available lottery types
  static List<String> getAvailableLotteryTypes() {
    return lotteryTypes.keys.toList();
  }
}
