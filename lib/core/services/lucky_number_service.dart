import 'dart:math';
import '../models/user_model.dart';
import '../models/lucky_number_model.dart';
import '../utils/numerology_utils.dart';
import '../utils/lottery_utils.dart';
import '../utils/date_utils.dart';

class LuckyNumberService {
  /// Generate complete daily lucky numbers with all details
  static LuckyNumbers generateDailyLuckyNumbers(
    UserProfile user, {
    String lotteryType = '6/49',
  }) {
    final now = DateTime.now();
    
    // Calculate core numerology
    final lifePathNumber = NumerologyUtils.calculateLifePathNumber(user.dateOfBirth);
    final destinyNumber = NumerologyUtils.calculateDestinyNumber(user.name);
    final dailyLuckyNumber = NumerologyUtils.calculateDailyLuckyNumber(lifePathNumber, now);
    final luckyHour = NumerologyUtils.calculateLuckyHour(lifePathNumber, now);
    
    // Get lottery numbers
    final primaryNumbers = LotteryUtils.generateLotteryNumbers(dailyLuckyNumber, lotteryType);
    
    // Generate secondary numbers (different multipliers)
    final secondaryNumbers = _generateSecondaryNumbers(dailyLuckyNumber, lotteryType);
    
    // Generate lucky digits (0-9)
    final luckyDigits = _generateLuckyDigits(dailyLuckyNumber, destinyNumber);
    
    // Get energy level
    final energyLevelData = _calculateEnergyLevel(dailyLuckyNumber, lifePathNumber, now);
    
    // Get lucky color
    final luckyColor = _getLuckyColor(dailyLuckyNumber);
    
    // Get zodiac influence
    final zodiacInfluence = user.zodiacSign;
    
    return LuckyNumbers(
      primaryNumbers: primaryNumbers,
      secondaryNumbers: secondaryNumbers,
      luckyDigits: luckyDigits,
      energyLevel: energyLevelData['value'] as int,
      energyStatus: energyLevelData['status'] as String,
      luckyColor: luckyColor,
      luckyColorHex: _getLuckyColorHex(dailyLuckyNumber),
      zodiacInfluence: zodiacInfluence,
      generatedDate: now,
      lifePathNumber: lifePathNumber,
      destinyNumber: destinyNumber,
      dailyLuckyNumber: dailyLuckyNumber,
      luckyHour: luckyHour,
      moonPhase: DateUtils.getMoonPhase(now),
      planetaryDay: DateUtils.getPlanetaryDay(now),
      fortuneMessage: DateUtils.getFortuneMessage(luckyHour),
    );
  }

  /// Generate secondary lucky numbers with different approach
  static List<int> _generateSecondaryNumbers(int dailyLuckyNumber, String lotteryType) {
    final lottery = LotteryUtils.lotteryTypes[lotteryType];
    if (lottery == null) return [];

    final secondaryNumbers = <int>{};
    final multipliers = [11, 13, 17, 19];
    final range = lottery.maxRange - lottery.minRange + 1;

    for (var multiplier in multipliers) {
      if (secondaryNumbers.length >= 3) break;
      
      int number = (dailyLuckyNumber * multiplier) % range;
      if (number < lottery.minRange) {
        number += lottery.minRange;
      } else {
        number += lottery.minRange - 1;
      }
      
      number = number.clamp(lottery.minRange, lottery.maxRange);
      secondaryNumbers.add(number);
    }

    return secondaryNumbers.toList()..sort();
  }

  /// Generate lucky digits (single digits that are lucky today)
  static List<int> _generateLuckyDigits(int dailyLuckyNumber, int destinyNumber) {
    final digits = <int>{};
    
    // Add the core numbers
    digits.add(dailyLuckyNumber);
    digits.add(destinyNumber % 10);
    
    // Add derived numbers
    digits.add((dailyLuckyNumber + destinyNumber) % 10);
    digits.add((dailyLuckyNumber * 2) % 10);
    
    // Fill remaining with random but seeded digits
    final random = Random(DateTime.now().day);
    while (digits.length < 4) {
      digits.add(random.nextInt(10));
    }
    
    return digits.toList()..sort();
  }

  /// Calculate energy level based on numerology and moon phase
  static Map<String, dynamic> _calculateEnergyLevel(
    int dailyLuckyNumber,
    int lifePathNumber,
    DateTime date,
  ) {
    // Base calculation
    int energyValue = (dailyLuckyNumber * 10 + lifePathNumber * 5) % 100;
    
    // Adjust based on day of week
    final dayBonus = [5, 15, 10, 20, 8, 12, 18]; // Sunday to Saturday
    energyValue += dayBonus[date.weekday % 7];
    energyValue = energyValue % 100;
    
    // Ensure non-zero
    if (energyValue == 0) energyValue = 50;

    String status;
    if (energyValue >= 70) {
      status = '🔥 High - Maximum Cosmic Power!';
    } else if (energyValue >= 40) {
      status = '⚡ Medium - Favorable Energy';
    } else {
      status = '🌙 Low - Introspection Time';
    }

    return {
      'value': energyValue,
      'status': status,
    };
  }

  /// Get lucky color name for the daily lucky number
  static String _getLuckyColor(int luckyNumber) {
    const colorMap = {
      1: 'Red',
      2: 'White',
      3: 'Yellow',
      4: 'Blue',
      5: 'Green',
      6: 'Pink',
      7: 'Purple',
      8: 'Black',
      9: 'Gold',
    };
    
    return colorMap[luckyNumber] ?? 'Gold';
  }

  /// Get lucky color as hex code
  static String _getLuckyColorHex(int luckyNumber) {
    const hexMap = {
      1: '#FF4444', // Red
      2: '#FFFFFF', // White
      3: '#FFD700', // Yellow
      4: '#4444FF', // Blue
      5: '#44DD44', // Green
      6: '#FF88DD', // Pink
      7: '#9944FF', // Purple
      8: '#000000', // Black
      9: '#D4AF37', // Gold
    };
    
    return hexMap[luckyNumber] ?? '#D4AF37';
  }

  /// Generate astrology-based insight message
  static String generateAstrologyInsight(String zodiacSign, int energyLevel) {
    const insights = {
      'Aries': [
        '♈ Bold moves favor you today. Trust aggressive numbers!',
        '♈ Mars energy empowers odd numbers today.',
      ],
      'Taurus': [
        '♉ Stability is your strength. Even numbers align with you.',
        '♉ patience brings prosperity. Focus on grounded choices.',
      ],
      'Gemini': [
        '♊ Communication favors you. Pairs and pattern numbers shine.',
        '♊ Your intuition is sharp. Follow your instincts!',
      ],
      'Cancer': [
        '♋ Emotional intuition guides you today.',
        '♋ Trust your gut feelings about number choices.',
      ],
      'Leo': [
        '♌ Your confidence peaks today. Bold numbers shine!',
        '♌ Leadership energy amplifies lucky numbers.',
      ],
      'Virgo': [
        '♍ Analytical precision benefits you today.',
        '♍ Details matter. Review numbers carefully.',
      ],
      'Libra': [
        '♎ Balance and harmony empower you.',
        '♎ Paired numbers and symmetry favor you today.',
      ],
      'Scorpio': [
        '♏ Your power peaks today. Trust deep intuition!',
        '♏ Transformation energy surrounds you.',
      ],
      'Sagittarius': [
        '♐ Adventure and expansion favor you.',
        '♐ Take calculated risks with optimism!',
      ],
      'Capricorn': [
        '♑ Discipline and strategy empower you.',
        '♑ Structured approaches yield best results.',
      ],
      'Aquarius': [
        '♒ Innovation and uniqueness shine today.',
        '♒ Unconventional numbers favor you.',
      ],
      'Pisces': [
        '♓ Your intuition is at its peak.',
        '♓ Dreams and visions guide you toward fortune.',
      ],
    };

    final zodiacInsights = insights[zodiacSign] ?? [
      'The stars align in your favor today!',
      'Trust the cosmic flow.',
    ];
    
    final random = Random(DateTime.now().day);
    final insight = zodiacInsights[random.nextInt(zodiacInsights.length)];
    
    if (energyLevel >= 70) {
      return '$insight ✨ High cosmic energy amplifies your luck!';
    } else if (energyLevel >= 40) {
      return '$insight The cosmic energy supports steady progress.';
    } else {
      return '$insight Even during low energy, intuition is strong. Listen within. 🌙';
    }
  }
}
