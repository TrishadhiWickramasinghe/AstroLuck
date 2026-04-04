import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/lottery_history_model.dart';
import '../../core/models/user_model.dart';
import '../../core/models/lucky_number_model.dart';

class LocalStorageService {
  static const String userProfileKey = 'user_profile';
  static const String lotteryHistoryKey = 'lottery_history';
  static const String dailyLuckyNumbersKey = 'daily_lucky_numbers';
  static const String patternAnalysisKey = 'pattern_analysis';
  static const String appVisitKey = 'last_app_visit';
  static const String onboardingCompleteKey = 'onboarding_complete';

  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User Profile Methods
  Future<bool> saveUserProfile(UserProfile user) async {
    try {
      final jsonString = jsonEncode(user.toJson());
      return await _prefs.setString(userProfileKey, jsonString);
    } catch (e) {
      print('Error saving user profile: $e');
      return false;
    }
  }

  UserProfile? getUserProfile() {
    try {
      final jsonString = _prefs.getString(userProfileKey);
      if (jsonString == null) return null;
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserProfile.fromJson(jsonData);
    } catch (e) {
      print('Error retrieving user profile: $e');
      return null;
    }
  }

  Future<bool> deleteUserProfile() async {
    return await _prefs.remove(userProfileKey);
  }

  // Lucky Numbers Methods
  Future<bool> saveDailyLuckyNumbers(LuckyNumbers numbers) async {
    try {
      final jsonString = jsonEncode(numbers.toJson());
      return await _prefs.setString(dailyLuckyNumbersKey, jsonString);
    } catch (e) {
      print('Error saving lucky numbers: $e');
      return false;
    }
  }

  LuckyNumbers? getDailyLuckyNumbers() {
    try {
      final jsonString = _prefs.getString(dailyLuckyNumbersKey);
      if (jsonString == null) return null;
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      return LuckyNumbers.fromJson(jsonData);
    } catch (e) {
      print('Error retrieving lucky numbers: $e');
      return null;
    }
  }

  // Lottery History Methods
  Future<bool> addLotteryEntry(LotteryEntry entry) async {
    try {
      final historyList = getLotteryHistory() ?? [];
      historyList.add(entry);
      final jsonString = jsonEncode(
        historyList.map((e) => e.toJson()).toList(),
      );
      return await _prefs.setString(lotteryHistoryKey, jsonString);
    } catch (e) {
      print('Error adding lottery entry: $e');
      return false;
    }
  }

  List<LotteryEntry>? getLotteryHistory() {
    try {
      final jsonString = _prefs.getString(lotteryHistoryKey);
      if (jsonString == null) return null;
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((item) => LotteryEntry.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error retrieving lottery history: $e');
      return null;
    }
  }

  Future<bool> updateLotteryEntry(LotteryEntry entry) async {
    try {
      final historyList = getLotteryHistory() ?? [];
      final index = historyList.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        historyList[index] = entry;
        final jsonString = jsonEncode(
          historyList.map((e) => e.toJson()).toList(),
        );
        return await _prefs.setString(lotteryHistoryKey, jsonString);
      }
      return false;
    } catch (e) {
      print('Error updating lottery entry: $e');
      return false;
    }
  }

  Future<bool> deleteLotteryEntry(String entryId) async {
    try {
      final historyList = getLotteryHistory() ?? [];
      historyList.removeWhere((e) => e.id == entryId);
      final jsonString = jsonEncode(
        historyList.map((e) => e.toJson()).toList(),
      );
      return await _prefs.setString(lotteryHistoryKey, jsonString);
    } catch (e) {
      print('Error deleting lottery entry: $e');
      return false;
    }
  }

  // Onboarding Status
  Future<bool> setOnboardingComplete(bool complete) async {
    return await _prefs.setBool(onboardingCompleteKey, complete);
  }

  bool isOnboardingComplete() {
    return _prefs.getBool(onboardingCompleteKey) ?? false;
  }

  // App Visit Tracking
  Future<bool> saveLastAppVisit(DateTime visitTime) async {
    return await _prefs.setString(appVisitKey, visitTime.toIso8601String());
  }

  DateTime? getLastAppVisit() {
    try {
      final dateString = _prefs.getString(appVisitKey);
      if (dateString == null) return null;
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Utility Methods
  Future<bool> clearAllData() async {
    try {
      await _prefs.clear();
      return true;
    } catch (e) {
      print('Error clearing all data: $e');
      return false;
    }
  }

  bool hasUserProfile() {
    return _prefs.containsKey(userProfileKey);
  }

  Future<bool> clearLotteryHistory() async {
    try {
      await _prefs.remove(lotteryHistoryKey);
      return true;
    } catch (e) {
      print('Error clearing lottery history: $e');
      return false;
    }
  }
}
