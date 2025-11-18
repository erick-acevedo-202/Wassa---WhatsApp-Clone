import 'package:flutter/material.dart';
import 'package:wasaaaaa/screens/home/components/navbar.dart';

class StatesMenuScreen extends StatefulWidget {
  StatesMenuScreen({super.key});

  @override
  State<StatesMenuScreen> createState() => _StatesMenuScreenState();
}

class _StatesMenuScreenState extends State<StatesMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('states')),
      bottomNavigationBar: Navbar(
        selectedIndex: 1, // posición de esta pantalla en la barra
        onTap: (index) {
          // opcional, si quieres actualizar un estado local
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('ola');
          Navigator.pushNamed(context, "/states_add");
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
