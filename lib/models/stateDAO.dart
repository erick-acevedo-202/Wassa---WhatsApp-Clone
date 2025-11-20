import 'package:wasaaaaa/models/userDAO.dart';

class StateDAO {
  final String? id;
  final String uid;
  final String expiration;
  final String message;
  final String? media;
  final Map<String, dynamic> reactions;

  // <-- Nuevo campo opcional
  final UserDAO? user;

  StateDAO({
    this.id,
    required this.uid,
    required this.expiration,
    required this.message,
    this.media,
    required this.reactions,
    this.user,
  });

  factory StateDAO.fromMap(Map<String, dynamic> map) {
    return StateDAO(
      id: map['id'] as String?,
      uid: map['uid'] as String,
      expiration: map['expiration'] as String,
      message: map['message'] as String,
      media: map['media'],
      reactions: Map<String, dynamic>.from(map['reactions'] ?? {}),
      user: null, // no viene desde Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'expiration': expiration,
      'message': message,
      'media': media,
      'reactions': reactions,
      // user NO se guarda en Firestore
    };
  }

  // <-- agrégalo
  StateDAO copyWith({UserDAO? user}) {
    return StateDAO(
      id: id,
      uid: uid,
      expiration: expiration,
      message: message,
      media: media,
      reactions: reactions,
      user: user ?? this.user,
    );
  }
}
