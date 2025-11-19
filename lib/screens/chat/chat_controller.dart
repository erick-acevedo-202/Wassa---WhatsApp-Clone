import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      BuildContext context, String text, String receiverUserId) {
    ref.read(userDataProvider).whenData(
          (value) => chatRepository.sendTextMessage(
              context: context,
              text: text,
              receiverUserId: receiverUserId,
              senderUser: value!),
        );
  }

  Stream<List<RecentChatModel>> getRecentChatContacts() {
    print("GET RECENT CHAT CONTACTS");
    print(chatRepository.getChatContacts().first.toString());
    return chatRepository.getChatContacts();
  }
}
