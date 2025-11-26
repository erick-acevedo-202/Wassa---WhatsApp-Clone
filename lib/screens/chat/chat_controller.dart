import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/common/enums/message_enum.dart';
import 'package:wasaaaaa/models/groupDAO.dart';
import 'package:wasaaaaa/models/messageDAO.dart';
import 'package:wasaaaaa/models/recent_chat_model.dart';
import 'package:wasaaaaa/screens/chat/chat_repository.dart';
import 'package:wasaaaaa/screens/register/auth_controller.dart';

final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(
    chatRepository: chatRepository,
    ref: ref,
  );
});

class ChatController {
  final ChatRepository chatRepository;
  final Ref ref;
  ChatController({
    required this.chatRepository,
    required this.ref,
  });

  void sendTextMessage(
      BuildContext context, String text, String receiverUserId, bool isGroup) {
    ref.read(userDataProvider).whenData(
          (value) => chatRepository.sendTextMessage(
              context: context,
              text: text,
              receiverUserId: receiverUserId,
              senderUser: value!,
              isGroup: isGroup),
        );
  }

  void sendFileMessage(BuildContext context, File file, String receiverUserId,
      MessageEnum messageEnum, bool isGroup) {
    ref.read(userDataProvider).whenData(
          (value) => chatRepository.sendFileMessage(
              context: context,
              file: file,
              receiverUserId: receiverUserId,
              senderUser: value!,
              messageEnum: messageEnum,
              ref: ref,
              isGroup: isGroup),
        );
  }

  //
  void sendGIFMessage(BuildContext context, String gifUrl,
      String receiverUserId, MessageEnum messageEnum, bool isGroup) {
    int gifUrlPartIndex = gifUrl.lastIndexOf('-') + 1;
    String gifUrlPart = gifUrl.substring(gifUrlPartIndex);
    String newgifUrl = 'https://i.giphy.com/media/$gifUrlPart/200.gif';

    ref.read(userDataProvider).whenData(
          (value) => chatRepository.sendGIFMessage(
              context: context,
              gifUrl: newgifUrl,
              receiverUserId: receiverUserId,
              senderUser: value!,
              isGroup: isGroup),
        );
  }

  Stream<List<RecentChatModel>> getRecentChatContacts() {
    print("GET RECENT CHAT CONTACTS");
    print(chatRepository.getChatContacts().first.toString());
    return chatRepository.getChatContacts();
  }

  Stream<List<GroupDAO>> getRecentChatGroups() {
    return chatRepository.getChatGroups();
  }

  Stream<List<MessageDAO>> getChatStream(String receiverUserId) {
    return chatRepository.getChatStream(receiverUserId);
  }

  Stream<List<MessageDAO>> getGroupChatStream(String groupId) {
    return chatRepository.getGroupChatStream(groupId);
  }

  void setChatMessageSeen(BuildContext context, String receiverUserId,
      String messageId, bool isGroup) {
    chatRepository.setChatMessageSeen(
        context, receiverUserId, messageId, isGroup);
  }

  Stream<int> getUnreadCountFromUser(String contactId) {
    return chatRepository.getUnreadCountStreamFromUser(contactId);
  }

  Stream<int> getUnreadCountFromGroup(String groupId) {
    return chatRepository.getUnreadCountStreamFromGroup(groupId);
  }

  void resetUnreadCount(String chatId, bool isGroup) {
    if (isGroup) {
      chatRepository.resetGroupUnreadCount(chatId);
    } else {
      chatRepository.resetUserUnreadCount(chatId);
    }
  }
}
