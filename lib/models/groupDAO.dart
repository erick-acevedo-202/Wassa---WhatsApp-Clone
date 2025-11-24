class GroupDAO {
  final String senderId;
  final String name;
  final String groupId;
  final String lastMessage;
  final String groupPic;
  final List<String> membersUid;
  final DateTime timeSent;
  bool? isRead;
  int? unreadCount;
  GroupDAO(
      {required this.senderId,
      required this.name,
      required this.groupId,
      required this.lastMessage,
      required this.groupPic,
      required this.membersUid,
      required this.timeSent,
      this.isRead,
      this.unreadCount});

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'name': name,
      'groupId': groupId,
      'lastMessage': lastMessage,
      'groupPic': groupPic,
      'membersUid': membersUid,
      'timeSent': timeSent.millisecondsSinceEpoch,
    };
  }

  factory GroupDAO.fromMap(Map<String, dynamic> map) {
    return GroupDAO(
      senderId: map['senderId'] ?? '',
      name: map['name'] ?? '',
      groupId: map['groupId'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      groupPic: map['groupPic'] ?? '',
      membersUid: List<String>.from(map['membersUid']),
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
    );
  }
}
