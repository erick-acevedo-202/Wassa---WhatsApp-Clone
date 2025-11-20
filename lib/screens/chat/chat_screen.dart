import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/components/error.dart';
import 'package:wasaaaaa/components/loader.dart';
import 'package:wasaaaaa/screens/chat/widgets/chat.dart';
import 'package:wasaaaaa/screens/chat/widgets/chat_field_widget.dart';
import 'package:wasaaaaa/screens/register/auth_controller.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String name = args['name'] ?? '';
    final String uid = args['uid'] ?? '';
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
          stream: ref.read(authControllerProvider).streamUserData(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }
            if (snapshot.hasError) {
              ErrorScreen(
                error: snapshot.error.toString(),
              );
            }
            if (snapshot.data == null) {
              return ListTile(
                title: Text(name),
                subtitle: Text(""),
              );
            }

            final userData = snapshot.data!;
            return ListTile(
              title: Text(name),
              subtitle: Text(userData.isOnline ? "Online" : "Offline"),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.video_call_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: Chat(receiverUserId: uid)),
          ChatFieldWidget(
            receiverUserId: uid,
          )
        ],
      ),
    );
  }
}
