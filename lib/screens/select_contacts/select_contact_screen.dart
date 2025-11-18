import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/components/error.dart';
import 'package:wasaaaaa/components/loader.dart';
import 'package:wasaaaaa/screens/select_contacts/select_contact_controller.dart';

class SelectContactScreen extends ConsumerWidget {
  const SelectContactScreen({super.key});

  void selectContact(
      WidgetRef ref, Contact selectedContact, BuildContext context) {
    print(
        "SELECTED CONTACT ${selectedContact.displayName} NUM: ${selectedContact.phones[0].number} ");
    ref
        .read(SelectContactControllerProvider)
        .selectContact(selectedContact, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contactos"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
        ],
      ),
      body: ref.watch(getContactsProvider).when(
            data: (contactList) => ListView.builder(
              itemCount: contactList.length,
              itemBuilder: (context, index) {
                final contact = contactList[index];

                return InkWell(
                  onTap: () {
                    print(contact.phones[0].normalizedNumber);
                    selectContact(ref, contact, context);
                  },
                  child: ListTile(
                    title: Text(contact.displayName),
                    leading: contact.photo == null
                        ? null
                        : CircleAvatar(
                            backgroundImage: MemoryImage(contact.photo!),
                            radius: 30,
                          ),
                  ),
                );
              },
            ),
            error: (e, trace) => ErrorScreen(error: e.toString()),
            loading: () => Loader(),
          ),
    );
  }
}
