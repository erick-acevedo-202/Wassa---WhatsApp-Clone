import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/models/stateDAO.dart';
import 'package:wasaaaaa/screens/home/components/navbar.dart';
import 'package:wasaaaaa/screens/states/states_controller.dart';
import 'package:wasaaaaa/screens/states/states_see_screen.dart';

class StatesMenuScreen extends ConsumerStatefulWidget {
  StatesMenuScreen({super.key});

  @override
  ConsumerState<StatesMenuScreen> createState() => _StatesMenuScreenState();
}

class _StatesMenuScreenState extends ConsumerState<StatesMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Estados'),
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
            Text('Estados de los demás'),
            StreamBuilder<List<StateDAO>>(
              stream:
                  ref.watch(stateControllerProvider).getStatesForChatContacts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No hay estados"));
                }

                final states = snapshot.data!;

                return Expanded(
                  child: ListView.builder(
                    itemCount: states.length,
                    itemBuilder: (context, index) {
                      final state = states[index];
                      final user = state.user;

                      return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StatesSeeScreen(state: state),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundImage: (user?.profilePic != null &&
                                  user!.profilePic.isNotEmpty)
                              ? NetworkImage(user.profilePic)
                              : null,
                          child: (user == null || user.profilePic.isEmpty)
                              ? Icon(Icons.person)
                              : null,
                        ),
                        title: Text(user?.name ?? "Usuario desconocido"),
                        subtitle: Text(state.message),
                        trailing: Text(
                          state.expiration
                              .substring(11, 16), // HH:mm si viene en ISO
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    },
                  ),
                );
              },
            )
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
