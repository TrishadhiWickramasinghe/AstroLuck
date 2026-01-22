import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

class UserRepository {
  UserProfile? getCurrentUser() {
    // TODO: Implement with local storage or backend
    return UserProfile(
      id: '1',
      name: 'User',
      dateOfBirth: DateTime(1990, 1, 15),
      zodiacSign: 'Capricorn',
      birthPlace: 'Earth',
    );
  }

  Future<void> saveUser(UserProfile user) async {
    // TODO: Implement with local storage or backend
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});
