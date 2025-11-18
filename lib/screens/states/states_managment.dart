import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/firebaseStorage/firabase_storage_repo.dart';
import 'package:wasaaaaa/models/stateDAO.dart';

final StatesManagmentProvider = Provider((ref) {
  return StatesManagment(
    firebase_auth: FirebaseAuth.instance,
    firebase_firestore: FirebaseFirestore.instance,
  );
});

class StatesManagment {
  final FirebaseAuth firebase_auth;
  final FirebaseFirestore firebase_firestore;

  StatesManagment(
      {required this.firebase_firestore, required this.firebase_auth});

  void createState({
    required BuildContext context,
    required String message,
    required String expiration,
    File? media,
    required Ref ref,
  }) async {
    try {
      String uid = firebase_auth.currentUser!.uid;
      String? url_media;

      if (media != null) {
        url_media = await ref.read(FirabaseStorageRepoProvider).storeFile(
            ref:
                'image_profile/$uid/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
            file: media);
      }
      final post = StateDAO(
          uid: uid,
          expiration: expiration,
          media: url_media,
          message: message,
          reactions: {});

      await firebase_firestore.collection('states').doc().set(post.toMap());

      Navigator.of(context).pushNamedAndRemoveUntil('/states', (route) => false,
          arguments: 'ok');
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
