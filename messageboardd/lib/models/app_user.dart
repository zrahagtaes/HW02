class AppUser {
  String uid;
  String firstName;
  String lastName;
  String role;
  DateTime registeredAt;

  AppUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.registeredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'registeredAt': registeredAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      role: map['role'],
      registeredAt: DateTime.parse(map['registeredAt']),
    );
  }
}
