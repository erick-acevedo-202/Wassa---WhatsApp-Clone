import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/components/utils.dart';

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
              isFound = true;
              print("USER FOUND");
              break;
            }
          }
          print('=======================');
        },
      );

      if (!isFound) {
        showSnackBar(
            context: context, content: 'Este número no tiene Wassa instalado');
      } else {
        print("IR AL CHAT");
        Navigator.popAndPushNamed(context, '/chat');
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
