import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> getLocalUserData() async {
  final prefs = await SharedPreferences.getInstance();

  return {
    "name": prefs.getString("name"),
    "email": prefs.getString("email"),
    "dateOfBirth": prefs.getString("dob"),
    "zodiacSign": prefs.getString("zodiac"),
  };
}

Future<void> migrateToFirestore() async {
  final service = FirestoreService();
  final data = await getLocalUserData();

  await service.createUser({
    ...data,
    "createdAt": Timestamp.now(),
    "onboardingComplete": true,
  });
}

Future<void> clearLocalData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}