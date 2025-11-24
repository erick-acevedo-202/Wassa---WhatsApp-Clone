import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/models/callDAO.dart';

final CallFirebaseProvider = Provider((ref) {
  return CallFirebase(
    firebase_auth: FirebaseAuth.instance,
    firebase_firestore: FirebaseFirestore.instance,
  );
});

class CallFirebase {
  final FirebaseAuth firebase_auth;
  final FirebaseFirestore firebase_firestore;

  CallFirebase({required this.firebase_firestore, required this.firebase_auth});

  Future<String> createCall({
    required BuildContext context,
    required List<String> calleeIds,
    required String name,
  }) async {
    String uid = firebase_auth.currentUser!.uid;
    String token = generateAuthToken();
    final call = CallDAO(
      fecha: DateTime.now(),
      horaInicio: DateTime.now(),
      status: "withoutanswering",
      callerId: uid,
      calleeIds: calleeIds,
      authToken: token,
    );
    await firebase_firestore.collection('calls').doc().set(call.toMap());
    return token;
  }

  Future<void> updateCall(
      {required BuildContext context,
      required CallDAO call,
      required String answer}) async {
    final docRef = FirebaseFirestore.instance.collection('calls').doc(call.id!);

    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      print("Call not found");
      return null;
    }

    final currentStatus = snapshot.data()?['status'];

    if (currentStatus != "withoutanswering" && currentStatus != "accepted") {
      print("Call cannot be updated because it is already $currentStatus");
      return null;
    }

    await docRef.update({
      'status': answer,
    });
  }

  Stream<CallDAO?> listenLatestIncomingCall() {
    final uid = firebase_auth.currentUser!.uid;

    return firebase_firestore
        .collection('calls')
        .where('calleeIds', arrayContains: uid)
        .where('status', isEqualTo: 'withoutanswering')
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;

      // Convertir todos los docs a objetos
      final calls = snap.docs
          .map((doc) => CallDAO.fromMap(doc.data(), id: doc.id))
          .toList();

      // Ordenar por fecha descendente usando DateTime.parse
      calls.sort((a, b) => b.fecha.compareTo(a.fecha));

      // Retornar el más reciente
      return calls.first;
    });
  }

  Stream<List<CallDAO>> listenCallHistory() async* {
    final uid = firebase_auth.currentUser!.uid;

    final incoming = firebase_firestore
        .collection('calls')
        .where('calleeIds', arrayContains: uid)
        .snapshots();

    final outgoing = firebase_firestore
        .collection('calls')
        .where('callerId', isEqualTo: uid)
        .snapshots();

    await for (final snapIn in incoming) {
      final snapOut = await outgoing.first;

      final callsIn = snapIn.docs
          .map((doc) => CallDAO.fromMap(doc.data(), id: doc.id))
          .toList();

      final callsOut = snapOut.docs
          .map((doc) => CallDAO.fromMap(doc.data(), id: doc.id))
          .toList();

      final all = [...callsIn, ...callsOut];

      all.sort((a, b) => b.fecha.compareTo(a.fecha));

      yield all;
    }
  }

  String generateAuthToken() {
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2ZXJzaW9uIjoyLCJ0eXBlIjoiYXBwIiwiYXBwX2RhdGEiOm51bGwsImFjY2Vzc19rZXkiOiI2OTFlODcxZDE0NWNiNGU4NDQ5YjFiNzYiLCJyb2xlIjoiaG9zdCIsInJvb21faWQiOiI2OTFlYTViOWE0OGNhNjFjNDY0N2UwZTQiLCJ1c2VyX2lkIjoiZjdlNDI2N2ItOGNjOC00NWIzLWFiZWQtMDc0M2Y1MDZhMjc1IiwiZXhwIjoxNzY0MDQwNTM0LCJqdGkiOiI1Y2VjZjAzMy0yZjYzLTRhMzAtOTkxMC0yMjZkYzAxODgxNjIiLCJpYXQiOjE3NjM5NTQxMzQsImlzcyI6IjY5MWU4NzFkMTQ1Y2I0ZTg0NDliMWI3NCIsIm5iZiI6MTc2Mzk1NDEzNCwic3ViIjoiYXBpIn0.EtbR3O5y2ZCufWyksQg45GBbOILOt7CPGU5BOzx78GA';
  }

  Future<String?> getUserNameById(String uid) async {
    final snap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!snap.exists) return null;

    return snap.data()?['name']; // o el campo correcto
  }
}
