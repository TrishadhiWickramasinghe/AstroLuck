class UserProfile {
  final String id;
  final String name;
  final DateTime dateOfBirth;
  final String? timeOfBirth; // Optional but powerful for astrology
  final String birthPlace;
  final String? gender; // Optional
  final String zodiacSign;
  final int lifePathNumber;
  final int destinyNumber;
  final List<String> favoriteLotteryTypes;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  UserProfile({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    this.timeOfBirth,
    required this.birthPlace,
    this.gender,
    required this.zodiacSign,
    required this.lifePathNumber,
    required this.destinyNumber,
    required this.favoriteLotteryTypes,
    required this.createdAt,
    this.lastUpdated,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      timeOfBirth: json['timeOfBirth'] as String?,
      birthPlace: json['birthPlace'] as String,
      gender: json['gender'] as String?,
      zodiacSign: json['zodiacSign'] as String,
      lifePathNumber: json['lifePathNumber'] as int,
      destinyNumber: json['destinyNumber'] as int,
      favoriteLotteryTypes: List<String>.from(json['favoriteLotteryTypes'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'timeOfBirth': timeOfBirth,
      'birthPlace': birthPlace,
      'gender': gender,
      'zodiacSign': zodiacSign,
      'lifePathNumber': lifePathNumber,
      'destinyNumber': destinyNumber,
      'favoriteLotteryTypes': favoriteLotteryTypes,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  /// Create a copy with some fields updated
  UserProfile copyWith({
    String? id,
    String? name,
    DateTime? dateOfBirth,
    String? timeOfBirth,
    String? birthPlace,
    String? gender,
    String? zodiacSign,
    int? lifePathNumber,
    int? destinyNumber,
    List<String>? favoriteLotteryTypes,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      timeOfBirth: timeOfBirth ?? this.timeOfBirth,
      birthPlace: birthPlace ?? this.birthPlace,
      gender: gender ?? this.gender,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      lifePathNumber: lifePathNumber ?? this.lifePathNumber,
      destinyNumber: destinyNumber ?? this.destinyNumber,
      favoriteLotteryTypes: favoriteLotteryTypes ?? this.favoriteLotteryTypes,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
