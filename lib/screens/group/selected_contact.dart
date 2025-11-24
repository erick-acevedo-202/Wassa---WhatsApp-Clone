import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:wasaaaaa/components/error.dart';
import 'package:wasaaaaa/components/loader.dart';
import 'package:wasaaaaa/screens/select_contacts/select_contact_controller.dart';

final selectedGroupContacts = StateProvider<List<Contact>>((ref) => []);

class SelectedContact extends ConsumerStatefulWidget {
  const SelectedContact({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectedContactState();
}

class _SelectedContactState extends ConsumerState<ConsumerStatefulWidget> {
  List<int> selectedContactsIndex = [];

  void selectContact(int index, Contact contact) {
    if (selectedContactsIndex.contains(index)) {
      selectedContactsIndex.removeAt(index);
    } else {
      selectedContactsIndex.add(index);
    }
    setState(() {});
    ref
        .read(selectedGroupContacts.notifier)
        .update((state) => [...state, contact]);
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(groupContactsProvider).when(
          data: (contacts) {
            if (contacts.isEmpty) {
              return const Center(
                child: Text("Ninguno de tus contactos tiene Wasaaaaa todavía"),
              );
            }

            return Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  final isSelected = selectedContactsIndex.contains(index);

                  return InkWell(
                    onTap: () => selectContact(index, contact),
                    child: ListTile(
                      leading: isSelected
                          ? const Icon(Icons.done, color: Colors.green)
                          : null,
                      title: Text(contact.displayName),
                      subtitle: Text(contact.phones.first.number),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Loader(),
          error: (err, _) => ErrorScreen(error: err.toString()),
        );
  }
}
