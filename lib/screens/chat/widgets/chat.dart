import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wasaaaaa/common/enums/message_enum.dart';
import 'package:wasaaaaa/components/error.dart';
import 'package:wasaaaaa/components/loader.dart';
import 'package:wasaaaaa/models/messageDAO.dart';
import 'package:wasaaaaa/screens/chat/chat_controller.dart';
import 'package:wasaaaaa/screens/chat/widgets/my_message_card.dart';
import 'package:wasaaaaa/screens/chat/widgets/receiver_message_card.dart';

class Chat extends ConsumerStatefulWidget {
  final String receiverUserId;
  final bool isGroup;
  const Chat({super.key, required this.receiverUserId, required this.isGroup});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatState();
}

class _ChatState extends ConsumerState<Chat> {
  final ScrollController messageController = ScrollController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MessageDAO>>(
      stream: widget.isGroup
          ? ref
              .read(chatControllerProvider)
              .getGroupChatStream(widget.receiverUserId)
          : ref
              .read(chatControllerProvider)
              .getChatStream(widget.receiverUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        if (snapshot.hasError) {
          return ErrorScreen(error: snapshot.error.toString());
        }

        //Cuando llegue un mensaje dar un salto hasta abajo
        SchedulerBinding.instance.addPostFrameCallback(
          (_) {
            messageController
                .jumpTo(messageController.position.maxScrollExtent);
          },
        );

        return ListView.builder(
          controller: messageController,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final messageData = snapshot.data![index];
            var timeSent = DateFormat.Hm().format(messageData.timeSent);

            if (!messageData.isSeen) {
              // Para grupos: cualquier mensaje no visto por cualquier usuario
              // Para chats 1:1: solo mensajes donde el receptor es el usuario actual
              if (widget.isGroup ||
                  messageData.receiverId ==
                      FirebaseAuth.instance.currentUser!.uid) {
                ref.read(chatControllerProvider).setChatMessageSeen(
                    context,
                    widget.receiverUserId,
                    messageData.messageId,
                    widget.isGroup);

                //Si veo los mensajes dentro del chat, resetear el contador, ya los vi
                ref
                    .read(chatControllerProvider)
                    .resetUnreadCount(widget.receiverUserId, widget.isGroup);
              }
            }

            /*
            print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");

            print("SNAPSHOT LENGTH: ${snapshot.data!.length}");
            print("SNAPSHOT DATA: ${snapshot.data![index].text}");
            print("SNAPSHOT TYPE: ${snapshot.data![index].type}");*/
            if (messageData.senderId ==
                FirebaseAuth.instance.currentUser!.uid) {
              return MyMessageCard(
                message: messageData.text,
                date: timeSent,
                type: messageData.type,
                isSeen: messageData.isSeen,
              );
            } else {
              return ReceiverMessageCard(
                  message: messageData.text,
                  date: timeSent,
                  type: messageData.type);
            }
          },
        );
      },
    );
  }
}
