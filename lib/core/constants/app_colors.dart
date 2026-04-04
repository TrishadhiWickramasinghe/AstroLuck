import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color gold = Color(0xFFD4AF37);
  static const Color purple = Color(0xFF6B5B95);
  static const Color darkPurple = Color(0xFF2D1B4E);
  static const Color lightPurple = Color(0xFFC8B8D8);
  static const Color background = Color(0xFF1A0F2E);
  static const Color darkBackground = Color(0xFF0F0820);
  static const Color cardBackground = Color(0xFF2A1E4D);

  // Accent colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color lightGrey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF424242);

  // Lucky Number Colors (1-9 mapping)
  static const Color luckyRed = Color(0xFFFF4444); // 1
  static const Color luckyWhite = Color(0xFFFFFFFF); // 2
  static const Color luckyYellow = Color(0xFFFFD700); // 3
  static const Color luckyBlue = Color(0xFF4444FF); // 4
  static const Color luckyGreen = Color(0xFF44DD44); // 5
  static const Color luckyPink = Color(0xFFFF88DD); // 6
  static const Color luckyPurpleNum = Color(0xFF9944FF); // 7
  static const Color luckyBlack = Color(0xFF000000); // 8
  static const Color luckyGold = Color(0xFFD4AF37); // 9

  // Zodiac colors
  static const Color aries = Color(0xFFFF4444);
  static const Color taurus = Color(0xFF88CC44);
  static const Color gemini = Color(0xFF44CCFF);
  static const Color cancer = Color(0xFFFF99FF);
  static const Color leo = Color(0xFFFFDD44);
  static const Color virgo = Color(0xFF99DD77);
  static const Color libra = Color(0xFFFFBB88);
  static const Color scorpio = Color(0xFF884499);
  static const Color sagittarius = Color(0xFF8855FF);
  static const Color capricorn = Color(0xFF333333);
  static const Color aquarius = Color(0xFF44AAFF);
  static const Color pisces = Color(0xFF88DDFF);

  // Energy level colors
  static const Color highEnergy = Color(0xFF44DD44); // High - Green
  static const Color mediumEnergy = Color(0xFFFFD700); // Medium - Gold
  static const Color lowEnergy = Color(0xFF8855FF); // Low - Purple

  // Status colors
  static const Color success = Color(0xFF44DD44);
  static const Color error = Color(0xFFFF4444);
  static const Color warning = Color(0xFFFFD700);
  static const Color info = Color(0xFF44CCFF);

  // Gradients
  static const LinearGradient cosmicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2D1B4E),
      Color(0xFF6B5B95),
    ],
  );

  static const LinearGradient deepCosmicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F0820),
      Color(0xFF2D1B4E),
    ],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD4AF37),
      Color(0xFFF1E5AC),
    ],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B6B),
      Color(0xFFFFE66D),
    ],
  );

  static const LinearGradient limeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF88CC44),
      Color(0xFF44DD44),
    ],
  );

  static const LinearGradient celestialGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2D1B4E),
      Color(0xFF6B5B95),
      Color(0xFFD4AF37),
    ],
  );

  // Shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0xFF000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> glowShadow = [
    BoxShadow(
      color: Color(0xFFD4AF37),
      blurRadius: 12,
      offset: Offset(0, 0),
    ),
  ];

  // Get color for lucky number (1-9)
  static Color getLuckyNumberColor(int number) {
    switch (number) {
      case 1: return luckyRed;
      case 2: return luckyWhite;
      case 3: return luckyYellow;
      case 4: return luckyBlue;
      case 5: return luckyGreen;
      case 6: return luckyPink;
      case 7: return luckyPurpleNum;
      case 8: return luckyBlack;
      case 9: return luckyGold;
      default: return gold;
    }
  }

  // Get zodiac color
  static Color getZodiacColor(String zodiacSign) {
    switch (zodiacSign.toLowerCase()) {
      case 'aries': return aries;
      case 'taurus': return taurus;
      case 'gemini': return gemini;
      case 'cancer': return cancer;
      case 'leo': return leo;
      case 'virgo': return virgo;
      case 'libra': return libra;
      case 'scorpio': return scorpio;
      case 'sagittarius': return sagittarius;
      case 'capricorn': return capricorn;
      case 'aquarius': return aquarius;
      case 'pisces': return pisces;
      default: return gold;
    }
  }
}
