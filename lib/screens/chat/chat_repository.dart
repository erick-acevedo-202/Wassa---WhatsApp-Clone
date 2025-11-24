import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wasaaaaa/common/enums/message_enum.dart';
import 'package:wasaaaaa/components/utils.dart';
import 'package:wasaaaaa/firebaseStorage/firabase_storage_repo.dart';
import 'package:wasaaaaa/models/groupDAO.dart';
import 'package:wasaaaaa/models/messageDAO.dart';
import 'package:wasaaaaa/models/recent_chat_model.dart';
import 'package:wasaaaaa/models/userDAO.dart';
import 'package:wasaaaaa/screens/register/auth_controller.dart';

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

  void _saveDataToRecentChat(
      UserDAO senderUser,
      UserDAO? receiverUser,
      String text,
      DateTime timeSent,
      String receiverUserId,
      bool isGroup) async {
    var receiverRecentChat = RecentChatModel(
        name: senderUser.name,
        profilePic: senderUser.profilePic,
        contactId: senderUser.uid,
        timeSent: timeSent,
        lastMessage: text);

    if (isGroup) {
      await firestore.collection('groups').doc(receiverUserId).update({
        'lastMessage': text,
        'timeSent': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      await firestore
          .collection('users')
          .doc(receiverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .set(receiverRecentChat.toMap());

      var senderRecentChat = RecentChatModel(
          name: receiverUser!.name,
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
  }

  void _saveMessage(
      {required String receiverUserId,
      required String text,
      required DateTime timeSent,
      required String messageId,
      required String senderUsername,
      required String? receiverUsername,
      required MessageEnum messageType,
      required bool isGroup}) async {
    final message = MessageDAO(
        senderId: auth.currentUser!.uid,
        receiverId: receiverUserId,
        text: text,
        type: messageType,
        timeSent: timeSent,
        messageId: messageId,
        isSeen: false);

    if (isGroup) {
      await firestore
          .collection('groups')
          .doc(receiverUserId)
          .collection('chats')
          .doc(messageId)
          .set(message.toMap());
    } else {
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
  }

  void sendTextMessage(
      {required BuildContext context,
      required String text,
      required String receiverUserId,
      required UserDAO senderUser,
      required bool isGroup}) async {
    try {
      var timeSent = DateTime.now();
      UserDAO? receiverUserData;

      if (!isGroup) {
        var userDataMap =
            await firestore.collection('users').doc(receiverUserId).get();

        receiverUserData = UserDAO.fromMap(userDataMap.data()!);
      }

      _saveDataToRecentChat(senderUser, receiverUserData, text, timeSent,
          receiverUserId, isGroup);

      var messageId = const Uuid().v1();

      _saveMessage(
          receiverUserId: receiverUserId,
          text: text,
          timeSent: timeSent,
          messageId: messageId,
          senderUsername: senderUser.name,
          receiverUsername: receiverUserData?.name,
          messageType: MessageEnum.text,
          isGroup: isGroup);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendFileMessage(
      {required BuildContext context,
      required File file,
      required String receiverUserId,
      required UserDAO senderUser,
      required Ref ref,
      required MessageEnum messageEnum,
      required bool isGroup}) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();
      UserDAO? receiverUserData;

      if (!isGroup) {
        var userDataMap =
            await firestore.collection('users').doc(receiverUserId).get();

        receiverUserData = UserDAO.fromMap(userDataMap.data()!);
      }

      String imgUrl = await ref.read(FirabaseStorageRepoProvider).storeFile(
          ref:
              '/chats/${messageEnum.type}/${senderUser.uid}/$receiverUserId/$messageId',
          file: file);

      String previewMsg;

      switch (messageEnum) {
        case MessageEnum.image:
          previewMsg = 'Foto ';
        case MessageEnum.video:
          previewMsg = 'Video ';
        case MessageEnum.audio:
          previewMsg = 'Audio ';
        case MessageEnum.gif:
          previewMsg = 'GIF ';
        default:
          previewMsg = 'GIF';
      }

      _saveDataToRecentChat(senderUser, receiverUserData, previewMsg, timeSent,
          receiverUserId, isGroup);

      _saveMessage(
          receiverUserId: receiverUserId,
          text: imgUrl,
          timeSent: timeSent,
          messageId: messageId,
          senderUsername: senderUser.name,
          receiverUsername: receiverUserData?.name,
          messageType: messageEnum,
          isGroup: isGroup);
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

  Stream<List<GroupDAO>> getChatGroups() {
    return firestore.collection('groups').snapshots().asyncMap((event) {
      List<GroupDAO> groups = [];
      for (var document in event.docs) {
        var chatGroup = GroupDAO.fromMap(document.data());
        if (chatGroup.membersUid.contains(auth.currentUser!.uid)) {
          groups.add(chatGroup);
        }
      }

      //Ordenar Chats recientes por hora (más reciente primero)
      groups.sort((a, b) => b.timeSent.compareTo(a.timeSent));

      return groups;
    });
  }

  Stream<List<MessageDAO>> getChatStream(String receiverUserId) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map(
      (event) {
        List<MessageDAO> messages = [];
        for (var doc in event.docs) {
          messages.add(MessageDAO.fromMap(doc.data()));
        }
        return messages;
      },
    );
  }

  Stream<List<MessageDAO>> getGroupChatStream(String groupId) {
    return firestore
        .collection('groups')
        .doc(groupId)
        .collection('chats')
        .orderBy('timeSent')
        .snapshots()
        .map(
      (event) {
        List<MessageDAO> messages = [];
        for (var doc in event.docs) {
          messages.add(MessageDAO.fromMap(doc.data()));
        }
        return messages;
      },
    );
  }

  void sendGIFMessage({
    required BuildContext context,
    required String gifUrl,
    required String receiverUserId,
    required UserDAO senderUser,
    required bool isGroup,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserDAO? receiverUserData;

      if (!isGroup) {
        var userDataMap =
            await firestore.collection('users').doc(receiverUserId).get();

        receiverUserData = UserDAO.fromMap(userDataMap.data()!);
      }

      var messageId = const Uuid().v1();

      _saveDataToRecentChat(
        senderUser,
        receiverUserData,
        'GIF',
        timeSent,
        receiverUserId,
        isGroup,
      );

      _saveMessage(
        receiverUserId: receiverUserId,
        text: gifUrl,
        timeSent: timeSent,
        messageType: MessageEnum.gif,
        messageId: messageId,
        senderUsername: senderUser.name,
        receiverUsername: receiverUserData?.name,
        isGroup: isGroup,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void setChatMessageSeen(
    BuildContext context,
    String receiverUserId,
    String messageId,
  ) async {
    try {
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(receiverUserId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});

      await firestore
          .collection('users')
          .doc(receiverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
