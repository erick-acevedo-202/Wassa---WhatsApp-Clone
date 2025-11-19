import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/components/error.dart';
import 'package:wasaaaaa/components/loader.dart';
import 'package:wasaaaaa/components/value_listener.dart';
import 'package:wasaaaaa/models/recent_chat_model.dart';
import 'package:wasaaaaa/screens/chat/chat_controller.dart';
import 'package:wasaaaaa/screens/home/components/navbar.dart';

class ChatsMenuScreen extends ConsumerWidget {
  ChatsMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget _buildMessageStatus(RecentChatModel recentChat) {
      if (recentChat.unreadCount > 0) {
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
              recentChat.unreadCount.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else if (recentChat.isRead) {
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

    Widget _buildRecentChatTile(RecentChatModel recentChat) {
      return ListTile(
        leading: recentChat.profilePic.isNotEmpty
            ? CircleAvatar(
                backgroundImage: NetworkImage(recentChat.profilePic),
                radius: 25,
              )
            : CircleAvatar(
                child: Icon(Icons.person, color: Colors.white),
                backgroundColor: Colors.grey,
                radius: 25,
              ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                recentChat.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _formatTime(recentChat.timeSent),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                recentChat.lastMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _buildMessageStatus(recentChat),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(context, '/chat', arguments: {
            'name': recentChat.name,
            'uid': recentChat.contactId
          });
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
      body: StreamBuilder(
        stream: ref.watch(chatControllerProvider).getRecentChatContacts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loader();
          }
          if (snapshot.hasError) {
            print(snapshot.data.toString());
            return ErrorScreen(error: snapshot.error.toString());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No Hay Chats"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var recentChat = snapshot.data![index];

              return _buildRecentChatTile(recentChat);
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
