class DateUtils {
  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get astrology-themed greeting based on time of day
  static String getAstrologicalGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return '🌙 Late Night Insights, Stargazer!';
    } else if (hour < 12) {
      return '🌅 Good Morning, Starseeker!';
    } else if (hour < 18) {
      return '☀️ Good Afternoon, Celestial Friend!';
    } else {
      return '🌙 Good Evening, Mystic Wanderer!';
    }
  }

  /// Get zodiac sign from date of birth
  static String getZodiacSign(DateTime dob) {
    final month = dob.month;
    final day = dob.day;

    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Aquarius';
    if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return 'Pisces';
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Scorpio';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Sagittarius';
    return 'Capricorn'; // Dec 22 - Jan 19
  }

  /// Get zodiac element (Fire, Water, Earth, Air)
  static String getZodiacElement(String zodiacSign) {
    const fireZodiacSigns = ['Aries', 'Leo', 'Sagittarius'];
    const waterZodiacSigns = ['Cancer', 'Scorpio', 'Pisces'];
    const earthZodiacSigns = ['Taurus', 'Virgo', 'Capricorn'];
    const airZodiacSigns = ['Gemini', 'Libra', 'Aquarius'];

    if (fireZodiacSigns.contains(zodiacSign)) return 'Fire';
    if (waterZodiacSigns.contains(zodiacSign)) return 'Water';
    if (earthZodiacSigns.contains(zodiacSign)) return 'Earth';
    if (airZodiacSigns.contains(zodiacSign)) return 'Air';
    return 'Unknown';
  }

  /// Get planetary day name (Monday = Mercury, etc.)
  static String getPlanetaryDay(DateTime date) {
    const days = [
      'Moon', // Sunday
      'Mercury', // Monday
      'Venus', // Tuesday
      'Mercury', // Wednesday
      'Jupiter', // Thursday
      'Venus', // Friday
      'Saturn', // Saturday
    ];
    return days[date.weekday % 7];
  }

  /// Get moon phase (approximate)
  static String getMoonPhase(DateTime date) {
    // Simplified calculation - uses known new moon date
    const lunaryMonth = 29.53; // Average lunar month length
    final knownNewMoon = DateTime(2000, 1, 6); // Known new moon date
    final daysDiff = date.difference(knownNewMoon).inDays;
    final moonAge = daysDiff % lunaryMonth.toInt();
    final phaseRatio = moonAge / lunaryMonth;

    if (phaseRatio < 0.25) return 'New Moon 🌑';
    if (phaseRatio < 0.5) return 'Waxing Moon 🌒';
    if (phaseRatio < 0.75) return 'Full Moon 🌕';
    return 'Waning Moon 🌘';
  }

  /// Calculate age from date of birth
  static int calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  /// Get fortune message based on time window
  static String getFortuneMessage(int luckyHour) {
    return 'Your lucky hour is $luckyHour:00 - $luckyHour:59 today! 🌟';
  }
}
