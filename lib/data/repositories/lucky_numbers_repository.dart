import '../../core/models/lucky_number_model.dart';
import '../local/local_storage.dart';

class LuckyNumbersRepository {
  final LocalStorageService _storage;

  LuckyNumbersRepository(this._storage);

  Future<bool> saveDailyLuckyNumbers(LuckyNumbers numbers) async {
    return await _storage.saveDailyLuckyNumbers(numbers);
  }

  LuckyNumbers? getDailyLuckyNumbers() {
    return _storage.getDailyLuckyNumbers();
  }

  bool hasValidDailyNumbers() {
    final numbers = _storage.getDailyLuckyNumbers();
    if (numbers == null) return false;
    
    // Check if numbers are from today
    final today = DateTime.now();
    final isSameDay = numbers.generatedDate.year == today.year &&
        numbers.generatedDate.month == today.month &&
        numbers.generatedDate.day == today.day;
    
    return isSameDay;
  }
}
