import '../models/user_model.dart';

class NumerologyUtils {
  static String generatePersonalFormula(UserProfile user) {
    // Calculate life path number
    final parts = user.dateOfBirth.toString().split('-');
    final day = int.parse(parts[2].substring(0, 2));
    final month = int.parse(parts[1]);
    final year = int.parse(parts[0]);

    int sum = _reduceToSingleDigit(day) +
        _reduceToSingleDigit(month) +
        _reduceToSingleDigit(year);

    final lifePathNumber = _reduceToSingleDigit(sum);

    return 'Life Path: $lifePathNumber';
  }

  static int _reduceToSingleDigit(int number) {
    while (number >= 10) {
      number = number.toString().split('').map(int.parse).reduce((a, b) => a + b);
    }
    return number;
  }
}
