class StateDAO {
  final String? id;
  final String uid;
  final String expiration;
  final String message;
  String? media;
  Map<String, dynamic> reactions;

  StateDAO(
      {this.id,
      required this.uid,
      required this.expiration,
      required this.message,
      this.media,
      required this.reactions});

  factory StateDAO.fromMap(Map<String, dynamic> map) {
    return StateDAO(
      id: map['id'] as String?,
      uid: map['uid'] as String,
      expiration: map['expiration'] as String,
      message: map['message'] as String,
      media: map['media'] ?? '',
      reactions: Map<String, dynamic>.from(map['reactions'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'uid': uid,
      'expiration': expiration,
      'message': message,
      'media': media,
      'reactions': reactions,
    };
  }
}
