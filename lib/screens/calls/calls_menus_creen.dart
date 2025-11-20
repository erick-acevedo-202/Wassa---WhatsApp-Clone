import 'package:flutter/material.dart';
import 'package:wasaaaaa/screens/home/components/navbar.dart';

class CallsMenusCreen extends StatefulWidget {
  CallsMenusCreen({super.key});

  @override
  State<CallsMenusCreen> createState() => _CallsMenusCreenState();
}

class _CallsMenusCreenState extends State<CallsMenusCreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Llamadas'),
        actions: [
          IconButton(
            icon: Icon(Icons.video_call),
            tooltip: 'Llamar ahora',
            onPressed: () {
              Navigator.pushNamed(context, '/call_now');
            },
          ),
        ],
      ),
      body: Center(child: Text('calls')),
      bottomNavigationBar: Navbar(
        selectedIndex: 2, // posición de esta pantalla en la barra
        onTap: (index) {
          // opcional, si quieres actualizar un estado local
        },
      ),
    );
  }
}
