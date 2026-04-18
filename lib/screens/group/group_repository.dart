import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wasaaaaa/components/utils.dart';
import 'package:wasaaaaa/firebaseStorage/firabase_storage_repo.dart';
import 'package:wasaaaaa/models/groupDAO.dart';
import 'package:wasaaaaa/models/userDAO.dart';

final groupRepositoryProvider = Provider(
  (ref) => GroupRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref,
  ),
);

class GroupRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final Ref ref;
  GroupRepository({
    required this.firestore,
    required this.auth,
    required this.ref,
  });

  void createGroup(BuildContext context, String name, File profilePic,
      List<Contact> selectedContact) async {
    try {
      List<String> uids = [];
      for (int i = 0; i < selectedContact.length; i++) {
        var userCollection = await firestore
            .collection('users')
            .where(
              'phoneNumber',
              isEqualTo: selectedContact[i].phones[0].number.replaceAll(
                    ' ',
                    '',
                  ),
            )
            .get();

        if (userCollection.docs.isNotEmpty && userCollection.docs[0].exists) {
          uids.add(userCollection.docs[0].data()['uid']);
        }
      }
      var groupId = const Uuid().v1();

      String profileUrl = await ref.read(FirabaseStorageRepoProvider).storeFile(
            ref: 'group/$groupId',
            file: profilePic,
          );

      GroupDAO group = GroupDAO(
        senderId: auth.currentUser!.uid,
        name: name,
        groupId: groupId,
        lastMessage: '',
        groupPic: profileUrl,
        membersUid: [auth.currentUser!.uid, ...uids],
        timeSent: DateTime.now(),
        unreadCount: 0,
        isRead: true,
      );

      await firestore.collection('groups').doc(groupId).set(group.toMap());
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Future<List<UserDAO>> getGroupMembers(String groupId) async {
    try {
      //Obtener el documento del grupo
      final groupDoc = await firestore.collection('groups').doc(groupId).get();

      if (!groupDoc.exists) {
        throw Exception("El grupo no existe");
      }
      final groupData = groupDoc.data()!;
      final List<String> memberUids =
          List<String>.from(groupData['membersUid'] ?? []);
      // Si no hay miembros, devolver lista vacía
      if (memberUids.isEmpty) return [];
      //Obtener todos los usuarios
      final List<Future<UserDAO>> futures = memberUids.map((uid) async {
        final userDoc = await firestore.collection('users').doc(uid).get();

        if (userDoc.exists) {
          final data = userDoc.data()!;
          data['uid'] = uid;
          return UserDAO.fromMap(data);
        } else {
          // Usuario no encontrado
          return UserDAO(
            uid: uid,
            phoneNumber: '',
            name: 'Usuario eliminado',
            email: '',
            description: '',
            profilePic: '',
            isOnline: false,
            groupId: [],
          );
        }
      }).toList();
      //Esperar resultados
      return await Future.wait(futures);
    } catch (e) {
      print("Error al obtener miembros del grupo: $e");
      rethrow;
    }
  }
}
