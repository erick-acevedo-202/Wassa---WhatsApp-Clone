import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wasaaaaa/common/enums/message_enum.dart';
import 'package:wasaaaaa/components/utils.dart';
import 'package:wasaaaaa/models/messageDAO.dart';
import 'package:wasaaaaa/models/recent_chat_model.dart';
import 'package:wasaaaaa/models/userDAO.dart';

final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  ChatRepository({
    required this.firestore,
    required this.auth,
  });

  void _saveDataToRecentChat(UserDAO senderUser, UserDAO receiverUser,
      String text, DateTime timeSent, String receiverUserId) async {
    var receiverRecentChat = RecentChatModel(
        name: senderUser.name,
        profilePic: senderUser.profilePic,
        contactId: senderUser.uid,
        timeSent: timeSent,
        lastMessage: text);

    await firestore
        .collection('users')
        .doc(receiverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(receiverRecentChat.toMap());

    var senderRecentChat = RecentChatModel(
        name: receiverUser.name,
        profilePic: receiverUser.profilePic,
        contactId: receiverUser.uid,
        timeSent: timeSent,
        lastMessage: text);

    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .set(senderRecentChat.toMap());
  }

  void _saveMessage({
    required String receiverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String senderUsername,
    required receiverUsername,
    required MessageEnum messageType,
  }) async {
    final message = MessageDAO(
        senderId: auth.currentUser!.uid,
        receiverId: receiverUserId,
        text: text,
        type: messageType,
        timeSent: timeSent,
        messageId: messageId,
        isSeen: false);

    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    await firestore
        .collection('users')
        .doc(receiverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());
  }

  void sendTextMessage(
      {required BuildContext context,
      required String text,
      required String receiverUserId,
      required UserDAO senderUser}) async {
    try {
      var timeSent = DateTime.now();
      UserDAO receiverUserData;

      var userDataMap =
          await firestore.collection('users').doc(receiverUserId).get();

      receiverUserData = UserDAO.fromMap(userDataMap.data()!);

      _saveDataToRecentChat(
          senderUser, receiverUserData, text, timeSent, receiverUserId);

      var messageId = const Uuid().v1();

      _saveMessage(
          receiverUserId: receiverUserId,
          text: text,
          timeSent: timeSent,
          messageId: messageId,
          senderUsername: senderUser.name,
          receiverUsername: receiverUserData.name,
          messageType: MessageEnum.text);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Stream<List<RecentChatModel>> getChatContacts() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<RecentChatModel> contacts = [];
      for (var document in event.docs) {
        print("##########################");
        print("");
        print("DOCUEMNT DATA:");
        print(document.data());

        print("");
        print("");
        print("##########################");
        var chatContact = RecentChatModel.fromMap(document.data());
        var userData = await firestore
            .collection('users')
            .doc(chatContact.contactId)
            .get();
        var user = UserDAO.fromMap(userData.data()!);

        contacts.add(
          RecentChatModel(
              name: user.name,
              profilePic: user.profilePic,
              contactId: chatContact.contactId,
              timeSent: chatContact.timeSent,
              lastMessage: chatContact.lastMessage,
              isRead: chatContact.isRead,
              unreadCount: chatContact.unreadCount),
        );
      }

      //Ordenar Chats recientes por hora (más reciente primero)
      contacts.sort((a, b) => b.timeSent.compareTo(a.timeSent));

      print("CONTACTS: ");
      print(contacts.toString());
      return contacts;
    });
  }
}
