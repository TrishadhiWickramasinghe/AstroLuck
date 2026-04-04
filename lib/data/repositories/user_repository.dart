import '../../core/models/user_model.dart';
import '../local/local_storage.dart';

class UserRepository {
  final LocalStorageService _storage;

  UserRepository(this._storage);

  Future<bool> saveUser(UserProfile user) async {
    return await _storage.saveUserProfile(user);
  }

  UserProfile? getCurrentUser() {
    return _storage.getUserProfile();
  }

  bool hasUser() {
    return _storage.hasUserProfile();
  }

  Future<bool> deleteUser() async {
    return await _storage.deleteUserProfile();
  }

  Future<void> updateUserLotteryPreferences(List<String> lotteryTypes) async {
    final user = _storage.getUserProfile();
    if (user != null) {
      final updatedUser = user.copyWith(
        favoriteLotteryTypes: lotteryTypes,
        lastUpdated: DateTime.now(),
      );
      await _storage.saveUserProfile(updatedUser);
    }
  }
}
