import '../models/lottery_history_model.dart';
import '../local/local_storage.dart';
import 'package:uuid/uuid.dart';

class LotteryRepository {
  final LocalStorageService _storage;

  LotteryRepository(this._storage);

  Future<bool> addEntry(LotteryEntry entry) async {
    return await _storage.addLotteryEntry(entry);
  }

  List<LotteryEntry> getHistory() {
    return _storage.getLotteryHistory() ?? [];
  }

  List<LotteryEntry> getHistoryByLotteryType(String lotteryType) {
    final history = _storage.getLotteryHistory() ?? [];
    return history.where((entry) => entry.lotteryType == lotteryType).toList();
  }

  Future<bool> updateEntry(LotteryEntry entry) async {
    return await _storage.updateLotteryEntry(entry);
  }

  Future<bool> deleteEntry(String entryId) async {
    return await _storage.deleteLotteryEntry(entryId);
  }

  int getWinCount() {
    final history = _storage.getLotteryHistory() ?? [];
    return history.where((entry) => entry.didWin).length;
  }

  /// Analyze patterns in lottery history
  PatternAnalysis analyzePatterns() {
    final history = _storage.getLotteryHistory() ?? [];
    
    if (history.isEmpty) {
      return PatternAnalysis(
        frequentDigits: [],
        rarelUsedDigits: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        digitFrequency: {},
        avoidThisWeek: [],
        recommendThisWeek: [3, 7, 9], // Default lucky numbers
        analysisMessage: 'No lottery history yet. Start adding entries!',
        analysisDate: DateTime.now(),
      );
    }

    // Count frequency of each digit
    final digitFrequency = <int, int>{};
    for (int i = 0; i < 10; i++) {
      digitFrequency[i] = 0;
    }

    for (var entry in history) {
      for (var number in entry.numbers) {
        // Count individual digits in the number
        final digits = number.toString().split('').map(int.parse).toList();
        for (var digit in digits) {
          digitFrequency[digit] = (digitFrequency[digit] ?? 0) + 1;
        }
      }
    }

    // Sort by frequency
    final sortedDigits = digitFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final frequentDigits = sortedDigits.take(4).map((e) => e.key).toList();
    final rarelyUsedDigits = sortedDigits.skip(6).map((e) => e.key).toList();

    // Get last 10 entries for "avoid this week" analysis
    final recentEntries = history.length > 10 
        ? history.sublist(history.length - 10) 
        : history;

    final usedThisWeek = <int>{};
    for (var entry in recentEntries) {
      for (var number in entry.numbers) {
        usedThisWeek.add(number % 10);
      }
    }

    final avoidThisWeek = usedThisWeek.toList();

    // Recommend digits that haven't been used recently
    final recommendThisWeek = <int>[];
    for (int i = 0; i < 10; i++) {
      if (!usedThisWeek.contains(i) && !recommendThisWeek.contains(i)) {
        recommendThisWeek.add(i);
        if (recommendThisWeek.length >= 4) break;
      }
    }

    // Fill with frequent digits if needed
    if (recommendThisWeek.length < 4) {
      for (var digit in frequentDigits) {
        if (!recommendThisWeek.contains(digit) && recommendThisWeek.length < 4) {
          recommendThisWeek.add(digit);
        }
      }
    }

    // Generate analysis message
    final winRate = (getWinCount() / history.length * 100).toStringAsFixed(1);
    final analysisMessage = 
      'Analyzed ${history.length} entries with $winRate% win rate. '
      'Frequent digits: ${frequentDigits.join(", ")}. ⚡';

    return PatternAnalysis(
      frequentDigits: frequentDigits,
      rarelUsedDigits: rarelyUsedDigits,
      digitFrequency: digitFrequency,
      avoidThisWeek: avoidThisWeek.toList(),
      recommendThisWeek: recommendThisWeek,
      analysisMessage: analysisMessage,
      analysisDate: DateTime.now(),
    );
  }

  /// Get statistics about lottery history
  Map<String, dynamic> getStatistics() {
    final history = _storage.getLotteryHistory() ?? [];
    
    if (history.isEmpty) {
      return {
        'totalEntries': 0,
        'totalWins': 0,
        'winRate': '0%',
        'favoriteType': 'N/A',
        'totalSpent': '\$0',
      };
    }

    final totalEntries = history.length;
    final totalWins = history.where((e) => e.didWin).length;
    final winRate = (totalWins / totalEntries * 100).toStringAsFixed(1);
    
    // Find favorite lottery type
    final typeFrequency = <String, int>{};
    for (var entry in history) {
      typeFrequency[entry.lotteryType] = (typeFrequency[entry.lotteryType] ?? 0) + 1;
    }
    
    final favoriteType = typeFrequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return {
      'totalEntries': totalEntries,
      'totalWins': totalWins,
      'winRate': '$winRate%',
      'favoriteType': favoriteType,
      'entriesByType': typeFrequency,
    };
  }

  /// Create new lottery entry
  static LotteryEntry createEntry({
    required String lotteryType,
    required List<int> numbers,
    int? bonusNumber,
    required DateTime drawDate,
    required bool didWin,
    String? prizeAmount,
    String? notes,
  }) {
    return LotteryEntry(
      id: const Uuid().v4(),
      lotteryType: lotteryType,
      numbers: numbers,
      bonusNumber: bonusNumber,
      drawDate: drawDate,
      addedDate: DateTime.now(),
      didWin: didWin,
      prizeAmount: prizeAmount,
      notes: notes,
    );
  }
}
