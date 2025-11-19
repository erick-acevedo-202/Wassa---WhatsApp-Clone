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
      appBar: AppBar(
        centerTitle: false,
        title: Text('Historias'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, "/states_from_you");
              },
              child: Card(
                margin: EdgeInsets.all(15),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.history, size: 28),
                      SizedBox(width: 15),
                      Text(
                        "Mis estados",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Navbar(
        selectedIndex: 1, // posición de esta pantalla en la barra
        onTap: (index) {
          // opcional, si quieres actualizar un estado local
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/states_add");
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
