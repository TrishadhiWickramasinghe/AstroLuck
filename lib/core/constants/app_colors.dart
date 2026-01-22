import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color gold = Color(0xFFD4AF37);
  static const Color purple = Color(0xFF6B5B95);
  static const Color darkPurple = Color(0xFF2D1B4E);
  static const Color lightPurple = Color(0xFFC8B8D8);
  static const Color background = Color(0xFF1A0F2E);

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

  // Gradients
  static const LinearGradient cosmicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2D1B4E),
      Color(0xFF6B5B95),
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
}
