import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wasaaaaa/components/error.dart';
import 'package:wasaaaaa/components/loader.dart';
import 'package:wasaaaaa/components/value_listener.dart';
import 'package:wasaaaaa/models/groupDAO.dart';
import 'package:wasaaaaa/models/recent_chat_model.dart';
import 'package:wasaaaaa/screens/chat/chat_controller.dart';
import 'package:wasaaaaa/screens/home/components/navbar.dart';

class ChatsMenuScreen extends ConsumerWidget {
  ChatsMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget _buildMessageStatus(bool isRead, int unreadCount) {
      if (unreadCount > 0) {
        // Mensajes sin leer - círculo con número
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              unreadCount.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else if (isRead) {
        // Mensaje leído - doble check azul
        return Icon(
          Icons.done_all,
          color: Colors.blue,
          size: 18,
        );
      } else {
        // Mensaje enviado pero no leído - doble check gris
        return Icon(
          Icons.done_all,
          color: Colors.grey,
          size: 18,
        );
      }
    }

    String _formatTime(DateTime time) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final messageDay = DateTime(time.year, time.month, time.day);

      if (messageDay == today) {
        return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
      } else if (messageDay == yesterday) {
        return 'Ayer';
      } else {
        return '${time.day}/${time.month}';
      }
    }

    Widget _buildRecentChatTile({
      RecentChatModel? recentChat,
      GroupDAO? recentGroup,
      required bool isGroup,
    }) {
      // Usamos el que NO sea null según el tipo
      final String chatName = isGroup ? recentGroup!.name : recentChat!.name;
      final String chatPic =
          isGroup ? recentGroup!.groupPic : recentChat!.profilePic;
      final String chatId =
          isGroup ? recentGroup!.groupId : recentChat!.contactId;
      final DateTime timeSent =
          isGroup ? recentGroup!.timeSent : recentChat!.timeSent;
      final String lastMessage = isGroup
          ? (recentGroup!.lastMessage ?? 'Sin mensajes')
          : recentChat!.lastMessage;

      // Estos campos en GroupDAO son opcionales → evitar null
      final bool isRead =
          isGroup ? (recentGroup!.isRead ?? true) : recentChat!.isRead;

      final int unreadCount =
          isGroup ? (recentGroup!.unreadCount ?? 0) : recentChat!.unreadCount;

      return ListTile(
        leading: chatPic.isNotEmpty
            ? CircleAvatar(
                backgroundImage: NetworkImage(chatPic),
                radius: 25,
              )
            : const CircleAvatar(
                child: Icon(Icons.person, color: Colors.white),
                backgroundColor: Colors.grey,
                radius: 25,
              ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                chatName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _formatTime(timeSent),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                lastMessage,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _buildMessageStatus(isRead, unreadCount),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/chat',
            arguments: {
              'name': chatName,
              'uid': chatId,
              'isGroup': isGroup,
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Wasaaaa'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'Marcar Leidos') {
                // acción Marcar Leidos
              } else if (value == 'Ajustes') {
                // acción Ajustes
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Marcar Leidos',
                child: Text('Marcar Leidos'),
              ),
              PopupMenuItem(
                value: 'Ajustes',
                child: Text('Ajustes'),
              ),
              PopupMenuItem(
                child: ValueListenableBuilder(
                  valueListenable: ValueListener.isLightTheme,
                  builder: (context, value, _) {
                    return ListTile(
                      leading: Icon(value ? Icons.nightlight : Icons.sunny),
                      title: Text(value ? 'Modo oscuro' : 'Modo claro'),
                      onTap: () {
                        ValueListener.isLightTheme.value = !value;
                        Navigator.pop(context); // cerrar popup
                      },
                    );
                  },
                ),
              )
            ],
          )
        ],
      ),
      bottomNavigationBar: Navbar(
        selectedIndex: 0,
        onTap: (index) {},
      ),
      body: StreamBuilder<List<dynamic>>(
        // Combinar 2 streams
        stream: CombineLatestStream.combine2(
          ref.watch(chatControllerProvider).getRecentChatGroups(),
          ref.watch(chatControllerProvider).getRecentChatContacts(),
          (List<GroupDAO> groups, List<RecentChatModel> chats) {
            // Lista unica de conversaciones
            final List<dynamic> allConversations = [...groups, ...chats];

            // Ordenar por fecha
            allConversations.sort((a, b) {
              final DateTime timeA = a is GroupDAO ? a.timeSent : a.timeSent;
              final DateTime timeB = b is GroupDAO ? b.timeSent : b.timeSent;
              return timeB.compareTo(timeA);
            });

            return allConversations;
          },
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Loader());
          }

          if (snapshot.hasError) {
            return ErrorScreen(error: snapshot.error.toString());
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return const Center(child: Text("Aún no tienes mensajes"));
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final item = conversations[index];

              if (item is GroupDAO) {
                return _buildRecentChatTile(recentGroup: item, isGroup: true);
              } else if (item is RecentChatModel) {
                return _buildRecentChatTile(recentChat: item, isGroup: false);
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
      // buildRecentChatsList(recentChats),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/contacts');
        },
        child: const Icon(Icons.add_comment_rounded),
      ),
    );
  }
}

/*Widget buildRecentChatsList(List<RecentChatModel> chats) {
      return ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          return _buildRecentChatTile(chats[index]);
        },
      );
    }*

List<RecentChatModel> recentChats = [
  RecentChatModel(
    name: "María García",
    profilePic: "https://example.com/photo1.jpg",
    contactId: "user123",
    timeSent: DateTime.now().subtract(Duration(minutes: 5)),
    lastMessage: "Hola, ¿cómo estás?",
    isRead: true,
    unreadCount: 0,
  ),
  RecentChatModel(
    name: "Juan Pérez",
    profilePic: "",
    contactId: "user456",
    timeSent: DateTime.now().subtract(Duration(hours: 2)),
    lastMessage: "Nos vemos mañana en la oficina",
    isRead: false,
    unreadCount: 3,
  ),
  RecentChatModel(
    name: "Ana López",
    profilePic: "https://example.com/photo3.jpg",
    contactId: "user789",
    timeSent: DateTime.now().subtract(Duration(days: 1)),
    lastMessage: "Gracias por tu ayuda!",
    isRead: false,
    unreadCount: 0,
  ),
];*/
