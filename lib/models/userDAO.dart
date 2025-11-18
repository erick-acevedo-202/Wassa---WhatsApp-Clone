class UserDAO {
  final String uid;
  final String phoneNumber;
  final String name;
  final String email;
  final String description;
  final String profilePic;
  final bool isOnline;
  final List<dynamic> groupId;

  UserDAO({
    required this.uid,
    required this.phoneNumber,
    required this.name,
    required this.email,
    required this.description,
    required this.isOnline,
    required this.profilePic,
    required this.groupId,
  });

  factory UserDAO.fromMap(Map<String, dynamic> mapa) {
    return UserDAO(
      uid: mapa['uid'] ?? '',
      phoneNumber: mapa['phoneNumber'] ?? '',
      name: mapa['name'] ?? '',
      email: mapa['email'] ?? '',
      description: mapa['description'] ?? '',
      isOnline: mapa['isOnline'] ?? false,
      profilePic: mapa['profilePic'] ?? '',
      groupId: (mapa['groupId'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "phoneNumber": phoneNumber,
      "name": name,
      "email": email,
      "description": description,
      "isOnline": isOnline,
      "profilePic": profilePic,
      "groupId": groupId,
    };
  }
}
