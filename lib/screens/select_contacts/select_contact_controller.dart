import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/screens/select_contacts/select_contact_repository.dart';

final groupContactsProvider = FutureProvider<List<Contact>>((ref) async {
  return ref.watch(SelectContactRespositoryProvider).getAppContacts();
});

final getContactsProvider = FutureProvider(
  (ref) {
    final SelectContactRespository =
        ref.watch(SelectContactRespositoryProvider);
    return SelectContactRespository.getContacts();
  },
);

final SelectContactControllerProvider = Provider(
  (ref) {
    final SelectContactRespository =
        ref.watch(SelectContactRespositoryProvider);
    return SelectContactController(
        ref: ref, selectContactRespository: SelectContactRespository);
  },
);

class SelectContactController {
  final Ref ref;
  final SelectContactRespository selectContactRespository;
  SelectContactController({
    required this.ref,
    required this.selectContactRespository,
  });

  void selectContact(Contact selectedContact, BuildContext context) {
    print(
        "SELECTED CONTACT CONTROLLER ${selectedContact.displayName} NUM: ${selectedContact.phones[0].number} ");
    selectContactRespository.selectContact(selectedContact, context);
  }
}
