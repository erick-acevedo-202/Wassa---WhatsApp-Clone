import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:wasaaaaa/models/callDAO.dart';
import 'package:crypto/crypto.dart';

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
    String token = await generateAuthToken();
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
      return null;
    }

    final currentStatus = snapshot.data()?['status'];

    if (currentStatus != "withoutanswering" && currentStatus != "accepted") {
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

      final calls = snap.docs
          .map((doc) => CallDAO.fromMap(doc.data(), id: doc.id))
          .toList();

      calls.sort((a, b) => b.fecha.compareTo(a.fecha));

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

  String createRoomAndGetHostToken() {
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2ZXJzaW9uIjoyLCJ0eXBlIjoiYXBwIiwiYXBwX2RhdGEiOm51bGwsImFjY2Vzc19rZXkiOiI2OTFlODcxZDE0NWNiNGU4NDQ5YjFiNzYiLCJyb2xlIjoiaG9zdCIsInJvb21faWQiOiI2OTFlYTViOWE0OGNhNjFjNDY0N2UwZTQiLCJ1c2VyX2lkIjoiZjdlNDI2N2ItOGNjOC00NWIzLWFiZWQtMDc0M2Y1MDZhMjc1IiwiZXhwIjoxNzY0MDQwNTM0LCJqdGkiOiI1Y2VjZjAzMy0yZjYzLTRhMzAtOTkxMC0yMjZkYzAxODgxNjIiLCJpYXQiOjE3NjM5NTQxMzQsImlzcyI6IjY5MWU4NzFkMTQ1Y2I0ZTg0NDliMWI3NCIsIm5iZiI6MTc2Mzk1NDEzNCwic3ViIjoiYXBpIn0.EtbR3O5y2ZCufWyksQg45GBbOILOt7CPGU5BOzx78GA';
  }

  String _generateRandomRoomName() {
    const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
    final rand = Random();
    final randomStr =
        List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
    return "room_$randomStr";
  }

  String _generateJti() {
    const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
    final rand = Random();
    return List.generate(16, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<String> generateAuthToken() async {
    const String accessKey = "691e871d145cb4e8449b1b76";
    const String secretKey =
        "bDpPXs4g0Nyxuwn72jiPpE_iBgM1i-LMa3EMGh1J10wyCl913L4XLMr5enTU0TyOeG6Q8hEyzWjjfbSEoOT4H0RLxxEd_vHQEZpcXflJI162wFGhG9egsjt9WK8wlDBA8vVz__bZV9LgLkg8iZiXG_CuTUbd2hbD5pLKqn0748A=";
    const String templateId = "691e873074147bd574bbbc1e";
    const String role = "host";
    final roomName = _generateRandomRoomName();

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final iat = now - 5;
    final exp = now + 3600;
    final jti = _generateJti();

    final header = {"alg": "HS256", "typ": "JWT"};
    String b64(Map x) =>
        base64Url.encode(utf8.encode(json.encode(x))).replaceAll("=", "");

    final mgmtHeader = b64(header);
    final mgmtPayload = b64({
      "access_key": accessKey,
      "type": "management",
      "version": 2,
      "iat": iat,
      "exp": exp,
      "jti": jti,
    });

    final mgmtSig = base64Url
        .encode(
          Hmac(sha256, utf8.encode(secretKey))
              .convert(utf8.encode("$mgmtHeader.$mgmtPayload"))
              .bytes,
        )
        .replaceAll("=", "");

    final managementJwt = "$mgmtHeader.$mgmtPayload.$mgmtSig";

    final createRoomRes = await http.post(
      Uri.parse("https://api.100ms.live/v2/rooms"),
      headers: {
        "Authorization": "Bearer $managementJwt",
        "Content-Type": "application/json"
      },
      body: json.encode({
        "name": roomName,
        "template_id": templateId,
      }),
    );

    if (createRoomRes.statusCode != 200 && createRoomRes.statusCode != 201) {
      throw Exception("Error creando room: ${createRoomRes.body}");
    }

    final roomId = json.decode(createRoomRes.body)["id"];

    // ===== CLIENT TOKEN (host) =====
    final clientHeader = b64(header);
    final clientPayload = b64({
      "access_key": accessKey,
      "room_id": roomId,
      "role": role,
      "type": "app",
      "version": 2,
      "iat": iat,
      "exp": exp,
      "jti": _generateJti(),
    });

    final clientSig = base64Url
        .encode(
          Hmac(sha256, utf8.encode(secretKey))
              .convert(utf8.encode("$clientHeader.$clientPayload"))
              .bytes,
        )
        .replaceAll("=", "");

    final clientJwt = "$clientHeader.$clientPayload.$clientSig";

    return clientJwt;
  }

  Future<String?> getUserNameById(String uid) async {
    final snap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!snap.exists) return null;

    return snap.data()?['name'];
  }
}
