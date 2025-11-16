import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final AuthNumberProvider = Provider((ref) {
  return AuthNumber(
    firebase_auth: FirebaseAuth.instance,
    firebase_firestore: FirebaseFirestore.instance,
  );
});

class AuthNumber {
  final FirebaseAuth firebase_auth;
  final FirebaseFirestore firebase_firestore;

  AuthNumber({required this.firebase_auth, required this.firebase_firestore});

  void singInWithNumber(BuildContext context, String phone) async {
    String verId = "";
    try {
      await firebase_auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await firebase_auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Código: ${e.code}"),
                      SizedBox(height: 8),
                      Text("Mensaje: ${e.message}"),
                      SizedBox(height: 8),
                      Text("Plugin: ${e.plugin}"),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          verId = verificationId;
          Navigator.pushNamed(context, "/otp", arguments: verId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text("Mensaje: ${e.toString()}")],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }
}
