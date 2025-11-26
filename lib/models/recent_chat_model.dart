class RecentChatModel {
  final String name;
  final String profilePic;
  final String contactId;
  final DateTime timeSent;
  final String lastMessage;
  final String lastMessageSenderId;
  bool isRead;
  int unreadCount;
  RecentChatModel(
      {required this.name,
      required this.profilePic,
      required this.contactId,
      required this.timeSent,
      required this.lastMessage,
      required this.lastMessageSenderId,
      this.isRead = false,
      this.unreadCount = 0});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profilePic': profilePic,
      'contactId': contactId,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'isRead': isRead,
      'unreadCount': unreadCount
    };
  }

  factory RecentChatModel.fromMap(Map<String, dynamic> map) {
    print(
        'RECENT CHAT MODEL MAP (Aqui esta intentando mappear el usuario y no el chat)${map.toString()}');
    return RecentChatModel(
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      contactId: map['contactId'] ?? '',
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      isRead: map['isRead'] ?? false,
      unreadCount: map['unreadCount'] is int ? map['unreadCount'] : 0,
    );
  }
}
