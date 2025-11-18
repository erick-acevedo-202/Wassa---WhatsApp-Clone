import 'package:wasaaaaa/screens/states/states_content.dart';

class StateDAO {
  final String uid; // usuario que publica
  final List<StateContent> content; // lista de contenidos
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> viewedBy; // uids de quienes lo han visto

  StateDAO({
    required this.uid,
    required this.content,
    DateTime? createdAt,
    DateTime? expiresAt,
    List<String>? viewedBy,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.expiresAt = expiresAt ?? DateTime.now().add(Duration(hours: 24)),
        this.viewedBy = viewedBy ?? [];

  factory StateDAO.fromMap(Map<String, dynamic> map) {
    return StateDAO(
      uid: map['uid'] ?? '',
      content: map['content'] != null
          ? List<StateContent>.from(
              (map['content'] as List).map((x) => StateContent.fromMap(x)))
          : [],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
      expiresAt: map['expiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['expiresAt'])
          : null,
      viewedBy:
          map['viewedBy'] != null ? List<String>.from(map['viewedBy']) : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'content': content.map((c) => c.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
      'viewedBy': viewedBy,
    };
  }

  /// Verifica si el estado sigue vigente
  bool get isActive => DateTime.now().isBefore(expiresAt);

  /// Marca el estado como visto por un usuario
  void markAsViewed(String viewerUid) {
    if (!viewedBy.contains(viewerUid)) {
      viewedBy.add(viewerUid);
    }
  }
}
