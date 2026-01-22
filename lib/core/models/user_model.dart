class UserProfile {
  final String id;
  final String name;
  final DateTime dateOfBirth;
  final String zodiacSign;
  final String birthPlace;

  UserProfile({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.zodiacSign,
    required this.birthPlace,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      zodiacSign: json['zodiacSign'] as String,
      birthPlace: json['birthPlace'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'zodiacSign': zodiacSign,
      'birthPlace': birthPlace,
    };
  }
}
