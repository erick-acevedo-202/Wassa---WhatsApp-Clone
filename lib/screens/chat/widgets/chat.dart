import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wasaaaaa/components/error.dart';
import 'package:wasaaaaa/components/loader.dart';
import 'package:wasaaaaa/models/messageDAO.dart';
import 'package:wasaaaaa/screens/chat/chat_controller.dart';
import 'package:wasaaaaa/screens/chat/widgets/my_message_card.dart';
import 'package:wasaaaaa/screens/chat/widgets/receiver_message_card.dart';

class Chat extends ConsumerStatefulWidget {
  final String receiverUserId;
  const Chat({super.key, required this.receiverUserId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatState();
}

class _ChatState extends ConsumerState<Chat> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MessageDAO>>(
      stream:
          ref.read(chatControllerProvider).getChatStream(widget.receiverUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        if (snapshot.hasError) {
          return ErrorScreen(error: snapshot.error.toString());
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final messageData = snapshot.data![index];
            var timeSent = DateFormat.Hm().format(messageData.timeSent);
            print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");

            print("SNAPSHOT LENGTH: ${snapshot.data!.length}");
            print("SNAPSHOT DATA: ${snapshot.data![index].text}");
            if (messageData.senderId ==
                FirebaseAuth.instance.currentUser!.uid) {
              return MyMessageCard(message: messageData.text, date: timeSent);
            } else {
              return ReceiverMessageCard(
                  message: messageData.text, date: timeSent);
            }
          },
        );
      },
    );
  }
}
