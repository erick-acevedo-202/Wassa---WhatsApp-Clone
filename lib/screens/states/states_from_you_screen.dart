import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/models/stateDAO.dart';
import 'package:wasaaaaa/screens/states/states_controller.dart';
import 'package:wasaaaaa/screens/states/states_see_screen.dart';

class StatesFromYouScreen extends ConsumerStatefulWidget {
  const StatesFromYouScreen({super.key});

  @override
  ConsumerState<StatesFromYouScreen> createState() =>
      _StatesFromYouScreenState();
}

class _StatesFromYouScreenState extends ConsumerState<StatesFromYouScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tus estados'),
      ),
      body: FutureBuilder<List<StateDAO>>(
        future: ref.read(stateControllerProvider).getStatesForUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final states = snapshot.data ?? [];

          if (states.isEmpty) {
            return Center(child: Text('No hay estados activos'));
          }

          return ListView.builder(
            itemCount: states.length,
            itemBuilder: (context, index) {
              final state = states[index];

              return Card(
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StatesSeeScreen(state: state),
                      ),
                    );
                  },
                  title: Text(state.message),
                  leading: state.media != null
                      ? Icon(Icons.attach_file)
                      : Icon(Icons.message),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _showConfirm(state);
                      // evento delete
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showConfirm(StateDAO state) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
            '¿Seguro que deseas eliminar este estado?\n\n'
            'Mensaje:\n${state.message}',
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text("Eliminar"),
              onPressed: () {
                Navigator.of(context).pop(); // cerrar diálogo

                // Aquí haces tu acción de borrar
                // EJEMPLO:
                ref
                    .read(stateControllerProvider)
                    .deleteState(state)
                    .then((onValue) {
                  setState(() {});
                });
              },
            ),
          ],
        );
      },
    );
  }
}
