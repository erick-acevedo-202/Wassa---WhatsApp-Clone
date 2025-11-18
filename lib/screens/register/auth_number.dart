import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/firebaseStorage/firabase_storage_repo.dart';
import 'package:wasaaaaa/models/userDAO.dart';

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
              print(e.toString());
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

  void verifyCode(
      {required BuildContext context,
      required String code,
      required String verId}) async {
    try {
      PhoneAuthCredential credential =
          PhoneAuthProvider.credential(verificationId: verId, smsCode: code);
      await firebase_auth.signInWithCredential(credential);
      Navigator.pushReplacementNamed(context, "/user_info");
    } catch (e) {}
  }

  void saveUserInfo({
    required BuildContext context,
    required String name,
    required String email,
    required File? image,
    required String? description,
    required Ref ref,
  }) async {
    final dialogContext = Navigator.of(context, rootNavigator: true).context;

    try {
      String uid = firebase_auth.currentUser!.uid;

      String default_photo_URL =
          'https://c8.alamy.com/comp/2WWHMDK/hand-drawn-lynx-head-retro-realistic-animal-isolated-vintage-style-doodle-line-graphic-design-black-and-white-drawing-mammal-vector-illustration-2WWHMDK.jpg';

      String? profile_photo_URL;

      if (image != null) {
        profile_photo_URL =
            await ref.read(FirabaseStorageRepoProvider).storeFile(
                  ref:
                      'image_profile/$uid/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
                  file: image,
                );
      } else {
        profile_photo_URL = default_photo_URL;
      }

      final user = UserDAO(
        uid: uid,
        phoneNumber: firebase_auth.currentUser!.phoneNumber!,
        name: name,
        email: email,
        description: description ?? '',
        isOnline: true,
        profilePic: profile_photo_URL,
        groupId: [],
      );

      await firebase_firestore.collection('users').doc(uid).set(user.toMap());

      Navigator.of(dialogContext)
          .pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      showDialog(
        context: dialogContext,
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

  Future<UserDAO?> getUserData() async {
    var data = await firebase_firestore
        .collection('users')
        .doc(firebase_auth.currentUser?.uid)
        .get();
    if (data.data() != null) {
      return UserDAO.fromMap(data.data()!);
    }
    return null;
  }
}
