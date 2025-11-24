import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/components/utils.dart';
import 'package:wasaaaaa/models/userDAO.dart';
import 'package:wasaaaaa/screens/register/auth_controller.dart';

final SelectContactRespositoryProvider = Provider(
  (ref) => SelectContactRespository(firestore: FirebaseFirestore.instance),
);

class SelectContactRespository {
  final FirebaseFirestore firestore;

  SelectContactRespository({
    required this.firestore,
  });

  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
    } catch (e) {
      print(e.toString());
    }

    return contacts;
  }

  void selectContact(Contact selectedContact, BuildContext context) async {
    try {
      if (selectedContact.phones.isEmpty) {
        showSnackBar(
            context: context, content: 'Este contacto no tiene número');
        return;
      }

      print(
          "SELECTED CONTACT RESPOSITORY ${selectedContact.displayName} NUM: ${selectedContact.phones[0].number} ");

      String selectedPhoneNum =
          selectedContact.phones[0].number.replaceAll(' ', '');
      print('################################');
      print(selectedPhoneNum);
      print('################################');

      bool isFound = false;

      var userCollection = await firestore.collection('users').get().then(
        (users) {
          // IMPRIMIR TODA LA COLECCIÓN
          print('=== USER COLLECTION ===');
          print('Número de documentos: ${users.docs.length}');
          print('Documentos:');
          for (var doc in users.docs) {
            //var userData = UserModel.fromMap(doc.data());
            print('Document ID: ${doc.id} ');
            print('Data: ${doc.data()}');
            print('Phone NUmber: ${doc.data()['phoneNumber']}');
            print('---');
            if (selectedPhoneNum == doc.data()['phoneNumber']) {
              var userData = UserDAO.fromMap(doc.data());
              isFound = true;
              print("USER FOUND");
              print("IR AL CHAT");
              Navigator.popAndPushNamed(context, '/chat',
                  arguments: {'name': userData.name, 'uid': userData.uid});
              break;
            }
          }
          print('=======================');
        },
      );

      if (!isFound) {
        showSnackBar(
            context: context, content: 'Este número no tiene Wassa instalado');
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Future<List<Contact>> getAppContacts() async {
    print("ENTRANDO EN GET APP CONTACTS");
    // 1. Pedir permiso
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      throw Exception("Permiso denegado");
    }

    final phoneContacts = await FlutterContacts.getContacts(
      withProperties: true,
      withThumbnail: false,
    );

    final List<String> phoneNumbers = phoneContacts
        .where((c) => c.phones.isNotEmpty)
        .map((c) =>
            c.phones.first.number.replaceAll(' ', '')) // solo traer digitos
        .toList();

    if (phoneNumbers.isEmpty) return [];

    print(phoneNumbers.toString());

    // 2. Batches de máximo 30 (límite de whereIn en Firestore)
    final List<List<String>> batches = [];
    for (var i = 0; i < phoneNumbers.length; i += 30) {
      batches.add(phoneNumbers.sublist(
        i,
        i + 30 > phoneNumbers.length ? phoneNumbers.length : i + 30,
      ));
    }

    final Set<String> appUserPhones = {};

    for (var batch in batches) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', whereIn: batch)
          .get();

      for (var doc in querySnapshot.docs) {
        final phone = doc.data()['phoneNumber'] as String?;
        print("*****************************************");
        print(phone);
        if (phone != null) {
          appUserPhones.add(phone.replaceAll(RegExp(r'\D'), '')); // normalizado
        }
      }
    }

    print(appUserPhones.toString());

    // 3. Filtrar solo los que están en la app
    return phoneContacts.where((contact) {
      if (contact.phones.isEmpty) return false;
      final cleanPhone =
          contact.phones.first.number.replaceAll(RegExp(r'\D'), '');
      return appUserPhones.contains(cleanPhone);
    }).toList();
  }
}
