import 'dart:io';

class StateDAO {
  final String uid;
  final String expiration;
  final String message;
  String? media;
  Map<String, dynamic> reactions;

  StateDAO(
      {required this.uid,
      required this.expiration,
      required this.message,
      this.media,
      required this.reactions});

  factory StateDAO.fromMap(Map<String, dynamic> map) {
    return StateDAO(
      uid: map['uid'] as String,
      expiration: map['expiration'] as String,
      message: map['message'] as String,
      media: map['media'] ?? null,
      reactions: Map<String, dynamic>.from(map['reactions'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'expiration': expiration,
      'message': message,
      'media': media,
      'reactions': reactions,
    };
  }
}
