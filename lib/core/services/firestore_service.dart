import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

/// Firestore Service - Direct Firestore database operations
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  late FirebaseFirestore _db;

  FirestoreService._internal();

  static FirestoreService get instance => _instance;

  void initialize() {
    _db = FirebaseService.instance.firestore;
  }

  // ========================================================================
  // USER PREFERENCES
  // ========================================================================

  /// Save user preferences
  Future<void> saveUserPreferences({
    required String userId,
    bool notificationsEnabled = true,
    String dailyReminderTime = '09:00',
    List<String> preferredLotteryTypes = const [],
    String theme = 'dark',
    String language = 'en',
  }) async {
    try {
      await _db.collection('preferences').doc(userId).set({
        'userId': userId,
        'notifications_enabled': notificationsEnabled,
        'daily_reminder_time': dailyReminderTime,
        'preferred_lottery_types': preferredLotteryTypes,
        'theme': theme,
        'language': language,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving preferences: $e');
      rethrow;
    }
  }

  /// Get user preferences
  Future<DocumentSnapshot> getUserPreferences(String userId) async {
    try {
      return await _db.collection('preferences').doc(userId).get();
    } catch (e) {
      print('Error fetching preferences: $e');
      rethrow;
    }
  }

  /// Stream user preferences
  Stream<DocumentSnapshot> streamUserPreferences(String userId) {
    return _db.collection('preferences').doc(userId).snapshots();
  }

  /// Update notification setting
  Future<void> updateNotificationSetting(String userId, bool enabled) async {
    try {
      await _db.collection('preferences').doc(userId).update({
        'notifications_enabled': enabled,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating notification setting: $e');
      rethrow;
    }
  }

  /// Update daily reminder time
  Future<void> updateDailyReminderTime(String userId, String time) async {
    try {
      await _db.collection('preferences').doc(userId).update({
        'daily_reminder_time': time,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating reminder time: $e');
      rethrow;
    }
  }

  // ========================================================================
  // CONFIG DATA
  // ========================================================================

  /// Get lottery configuration
  Future<DocumentSnapshot> getLotteryConfig() async {
    try {
      return await _db.collection('config').doc('lotteries').get();
    } catch (e) {
      print('Error fetching lottery config: $e');
      rethrow;
    }
  }

  /// Stream lottery configuration
  Stream<DocumentSnapshot> streamLotteryConfig() {
    return _db.collection('config').doc('lotteries').snapshots();
  }

  /// Get lucky colors configuration
  Future<DocumentSnapshot> getLuckyColorsConfig() async {
    try {
      return await _db.collection('config').doc('lucky_colors').get();
    } catch (e) {
      print('Error fetching lucky colors config: $e');
      rethrow;
    }
  }

  /// Stream lucky colors configuration
  Stream<DocumentSnapshot> streamLuckyColorsConfig() {
    return _db.collection('config').doc('lucky_colors').snapshots();
  }

  // ========================================================================
  // SEARCH & QUERY
  // ========================================================================

  /// Search lottery history by lottery type
  Future<QuerySnapshot> searchLotteryHistoryByType(
    String userId,
    String lotteryType,
  ) async {
    try {
      return await _db
          .collection('lotteryHistory')
          .where('userId', isEqualTo: userId)
          .where('lotteryType', isEqualTo: lotteryType)
          .orderBy('createdAt', descending: true)
          .get();
    } catch (e) {
      print('Error searching lottery history: $e');
      rethrow;
    }
  }

  /// Get lucky numbers for a specific date
  Future<QuerySnapshot> getLuckyNumbersForDate(
    String userId,
    String date,
  ) async {
    try {
      return await _db
          .collection('luckyNumbers')
          .where('userId', isEqualTo: userId)
          .where('day', isEqualTo: date)
          .get();
    } catch (e) {
      print('Error fetching lucky numbers for date: $e');
      rethrow;
    }
  }

  // ========================================================================
  // UTILITY METHODS
  // ========================================================================

  /// Delete user account (soft delete - marks as deleted)
  Future<void> deleteUserAccount(String userId) async {
    try {
      await _db.collection('users').doc(userId).update({
        'deleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error deleting user account: $e');
      rethrow;
    }
  }

  /// Check if user exists
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking if user exists: $e');
      return false;
    }
  }

  /// Get Firestore database reference
  FirebaseFirestore get db => _db;
}
