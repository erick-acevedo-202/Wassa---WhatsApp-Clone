import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/models/callDAO.dart';
import 'package:wasaaaaa/screens/calls/call_controller.dart';
import 'package:wasaaaaa/screens/home/components/navbar.dart';

class CallsMenusCreen extends ConsumerStatefulWidget {
  CallsMenusCreen({super.key});

  @override
  ConsumerState<CallsMenusCreen> createState() => _CallsMenusCreenState();
}

class _CallsMenusCreenState extends ConsumerState<CallsMenusCreen> {
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
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: ref.read(callControllerProvider).listenLatestIncomingCall(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const Text("");
              }

              final call = snapshot.data!;
              final diff = DateTime.now().difference(call.fecha);

              return FutureBuilder<String?>(
                future: ref
                    .read(callControllerProvider)
                    .getUserNameById(call.callerId),
                builder: (context, userSnap) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final name = userSnap.data ?? "Desconocido";
                  if (diff.inMinutes >= 2) {
                    return const SizedBox.shrink();
                  }

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Llamada entrante",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Text("Estado: ${call.status}"),
                          Text("De: $name"), // ← Aquí ya usamos el nombre real

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await ref
                                      .read(callControllerProvider)
                                      .updateCall(
                                        context: context,
                                        call: call,
                                        answer: "cancelled",
                                      );
                                },
                                child: const Text("Cancelar"),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    "/call_now",
                                    arguments: call.authToken,
                                  ).then((val) async {
                                    await ref
                                        .read(callControllerProvider)
                                        .updateCall(
                                          context: context,
                                          call: call,
                                          answer: "accepted",
                                        );
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                child: Text(
                                  "Contestar",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              'Historial',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
          StreamBuilder<List<CallDAO>>(
            stream: ref.read(callControllerProvider).listenCallHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No hay historial"));
              }

              final callList = snapshot.data!;

              return Expanded(
                child: ListView.builder(
                  itemCount: callList.length,
                  itemBuilder: (context, index) {
                    final call = callList[index];

                    // Tomamos el primer callee
                    final calleeId =
                        call.calleeIds.isNotEmpty ? call.calleeIds.first : null;

                    return FutureBuilder<String?>(
                      future: calleeId != null
                          ? ref
                              .read(callControllerProvider)
                              .getUserNameById(calleeId)
                          : Future.value("Desconocido"),
                      builder: (context, calleeSnap) {
                        if (calleeSnap.connectionState ==
                            ConnectionState.waiting) {
                          return const ListTile(
                            title: Text(""),
                          );
                        }

                        final calleeName = calleeSnap.data ?? "Desconocido";

                        return buildCallCard(call, calleeName);
                      },
                    );
                  },
                ),
              );
            },
          )
        ],
      ),
      bottomNavigationBar: Navbar(
        selectedIndex: 2, // posición de esta pantalla en la barra
        onTap: (index) {
          // opcional, si quieres actualizar un estado local
        },
      ),
    );
  }

  String formatFecha(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return "$day-$month-$year — $hour:$minute";
  }

  Widget buildCallCard(CallDAO call, String calleeName) {
    // Colores claros según estado
    Color bgColor;
    String estadoTexto;

    switch (call.status) {
      case "withoutanswering":
        bgColor = Colors.orange.shade100;
        estadoTexto = "Sin contestar";
        break;
      case "accepted":
        bgColor = Colors.green.shade100;
        estadoTexto = "Aceptada";
        break;
      case "cancelled":
        bgColor = Colors.red.shade100;
        estadoTexto = "Cancelada";
        break;
      default:
        bgColor = Colors.grey.shade200;
        estadoTexto = call.status;
    }

    return Card(
      color: bgColor,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del otro usuario
            Text(
              calleeName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // Fecha
            Text(
              formatFecha(call.fecha),
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 6),

            // Estado
            Text(
              estadoTexto,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
