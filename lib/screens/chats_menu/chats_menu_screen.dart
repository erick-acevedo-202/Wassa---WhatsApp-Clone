import 'package:flutter/material.dart';
import 'package:wasaaaaa/components/value_listener.dart';
import 'package:wasaaaaa/screens/home/components/navbar.dart';

class ChatsMenuScreen extends StatefulWidget {
  ChatsMenuScreen({super.key});

  @override
  State<ChatsMenuScreen> createState() => _ChatsMenuScreenState();
}

class _ChatsMenuScreenState extends State<ChatsMenuScreen> {
  @override
  Widget build(BuildContext context) {
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
        selectedIndex: 0, // posición de esta pantalla en la barra
        onTap: (index) {
          // opcional, si quieres actualizar un estado local
        },
      ),
      body: Center(child: Text('chats')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
