import '../models/user_model.dart';

class NumerologyUtils {
  // Letter to number mapping for name numbers
  static const Map<String, int> letterValues = {
    'A': 1, 'J': 1, 'S': 1,
    'B': 2, 'K': 2, 'T': 2,
    'C': 3, 'L': 3, 'U': 3,
    'D': 4, 'M': 4, 'V': 4,
    'E': 5, 'N': 5, 'W': 5,
    'F': 6, 'O': 6, 'X': 6,
    'G': 7, 'P': 7, 'Y': 7,
    'H': 8, 'Q': 8, 'Z': 8,
    'I': 9, 'R': 9,
  };

  /// Calculate Life Path Number from Date of Birth
  /// Formula: Sum all digits in DOB, reduce to single digit
  /// Example: 1999-08-21 → 1+9+9+9+0+8+2+1 = 39 → 3+9 = 12 → 1+2 = 3
  static int calculateLifePathNumber(DateTime dob) {
    final parts = dob.toString().split('-');
    final day = int.parse(parts[2].substring(0, 2));
    final month = int.parse(parts[1]);
    final year = int.parse(parts[0]);

    int sum = _sumDigits(day) + _sumDigits(month) + _sumDigits(year);
    return _reduceToSingleDigit(sum);
  }

  /// Calculate Destiny/Name Number from name
  /// Formula: Convert each letter to number, sum, reduce to single digit
  static int calculateDestinyNumber(String name) {
    int sum = 0;
    final cleanName = name.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    
    for (var char in cleanName.split('')) {
      sum += letterValues[char] ?? 0;
    }
    
    return _reduceToSingleDigit(sum);
  }

  /// Calculate Daily Lucky Number
  /// Formula: (Life Path + Day + Month + Year) % 9, if 0 use 9
  static int calculateDailyLuckyNumber(int lifePathNumber, DateTime date) {
    final day = date.day;
    final month = date.month;
    final year = date.year;
    
    int sum = lifePathNumber + day + month + year;
    int result = sum % 9;
    
    return result == 0 ? 9 : result;
  }

  /// Calculate Lucky Hour/Time Window
  /// Formula: (Life Path + Current Hour) % 24, if < 6 add 6 (avoid night)
  static int calculateLuckyHour(int lifePathNumber, DateTime now) {
    int hour = (lifePathNumber + now.hour) % 24;
    
    if (hour < 6) {
      hour += 6;
    }
    
    return hour;
  }

  /// Reduce any number to single digit
  static int _reduceToSingleDigit(int number) {
    while (number >= 10) {
      number = _sumDigits(number);
    }
    return number == 0 ? 9 : number;
  }

  /// Sum all digits in a number
  static int _sumDigits(int number) {
    int sum = 0;
    while (number > 0) {
      sum += number % 10;
      number ~/= 10;
    }
    return sum;
  }

  /// Generate personal formula as string
  static String generatePersonalFormula(UserProfile user) {
    final lifePathNumber = calculateLifePathNumber(user.dateOfBirth);
    final destinyNumber = calculateDestinyNumber(user.name);
    return 'LP: $lifePathNumber | DN: $destinyNumber';
  }
}
