import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/components/error.dart';
import 'package:wasaaaaa/components/loader.dart';
import 'package:wasaaaaa/screens/calls/call_controller.dart';
import 'package:wasaaaaa/screens/chat/widgets/chat.dart';
import 'package:wasaaaaa/screens/chat/widgets/chat_field_widget.dart';
import 'package:wasaaaaa/screens/register/auth_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        print("USER ONLINE ");
        ref.read(authControllerProvider).setUserStatus(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        print("USER OFFLINE ");
        ref.read(authControllerProvider).setUserStatus(false);
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String name = args['name'] ?? '';
    final String uid = args['uid'] ?? '';
    final bool isGroup = args['isGroup'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: isGroup
            ? Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              )
            : StreamBuilder(
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
            onPressed: () async {
              final tokenU = await ref.read(callControllerProvider).createCall(
                    context: context,
                    calleeIds: [uid],
                    name: name,
                  );
              Navigator.pushNamed(
                context,
                "/call_now",
                arguments: tokenU,
              );
            },
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
          Expanded(child: Chat(receiverUserId: uid, isGroup: isGroup)),
          ChatFieldWidget(receiverUserId: uid, isGroup: isGroup)
        ],
      ),
    );
  }
}
