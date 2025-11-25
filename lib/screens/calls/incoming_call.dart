import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/models/callDAO.dart';
import 'package:wasaaaaa/screens/calls/call_controller.dart';
import 'package:wasaaaaa/screens/calls/calls.dart';

class IncomingCallListener extends StatelessWidget {
  final Widget child;
  const IncomingCallListener({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseAuth firebase_auth = FirebaseAuth.instance;
    final uid = firebase_auth.currentUser!.uid;
    if (uid == null) {
      return child;
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance.collection('calls').doc(uid).snapshots(),
      builder: (context, snapshot) {
        // Logging completo

        if (snapshot.hasError) {
          return child;
        }

        if (!snapshot.hasData) return child;

        final doc = snapshot.data!;

        if (!doc.exists || doc.data() == null) return child;

        final data = doc.data()!;
        final hasDialled = data['hasDialled'];
        if (hasDialled == false) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: ((_) => CallsUsers()),
                fullscreenDialog: true,
              ),
            );
          });
          return child;
        }

        return child;
      },
    );
  }
}

class IncomingCallDialog extends ConsumerWidget {
  final CallDAO call;

  const IncomingCallDialog({required this.call});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text("Llamada entrante "),
      content: Text("te estan llamando..."),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(callControllerProvider).updateCall(
                  context: context,
                  call: call,
                  answer: "rejected",
                );
            Navigator.pop(context);
          },
          child: const Text("Reject"),
        ),
        TextButton(
          onPressed: () {
            ref.read(callControllerProvider).updateCall(
                  context: context,
                  call: call,
                  answer: "accepted",
                );
            Navigator.pop(context);
          },
          child: const Text("Answer"),
        ),
      ],
    );
  }
}
