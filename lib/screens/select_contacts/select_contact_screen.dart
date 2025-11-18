import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/components/error.dart';
import 'package:wasaaaaa/components/loader.dart';
import 'package:wasaaaaa/screens/select_contacts/select_contact_controller.dart';

class SelectContactScreen extends ConsumerStatefulWidget {
  const SelectContactScreen({super.key});

  @override
  ConsumerState<SelectContactScreen> createState() =>
      _SelectContactScreenState();
}

class _SelectContactScreenState extends ConsumerState<SelectContactScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void selectContact(Contact selectedContact) {
    print(
        "SELECTED CONTACT ${selectedContact.displayName} NUM: ${selectedContact.phones.isNotEmpty ? selectedContact.phones[0].number : ''}");
    ref
        .read(SelectContactControllerProvider)
        .selectContact(selectedContact, context);
  }

  List<Contact> _filterContacts(List<Contact> contacts, String query) {
    if (query.isEmpty) return contacts;

    final lowerQuery = query.toLowerCase();
    return contacts.where((contact) {
      final name = contact.displayName.toLowerCase();
      final phone = contact.phones.isNotEmpty
          ? contact.phones[0].normalizedNumber.toLowerCase()
          : '';
      return name.contains(lowerQuery) || phone.contains(lowerQuery);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar contacto...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text("Contactos"),
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _toggleSearch,
              )
            : null,
        actions: [
          _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _toggleSearch();
                    /*_searchController.clear();
                    setState(() => _searchQuery = '');*/
                  },
                )
              : IconButton(
                  onPressed: _toggleSearch,
                  icon: const Icon(Icons.search),
                ),
          if (!_isSearching)
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: ref.watch(getContactsProvider).when(
            data: (contactList) {
              final filteredContacts =
                  _filterContacts(contactList, _searchQuery);

              if (filteredContacts.isEmpty && _searchQuery.isNotEmpty) {
                return const Center(child: Text("No se encontraron contactos"));
              }

              return ListView.builder(
                itemCount: filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = filteredContacts[index];
                  return InkWell(
                    onTap: () => selectContact(contact),
                    child: ListTile(
                      leading: contact.photo == null
                          ? const CircleAvatar(child: Icon(Icons.person))
                          : CircleAvatar(
                              backgroundImage: MemoryImage(contact.photo!),
                              radius: 30,
                            ),
                      title: Text(contact.displayName),
                      subtitle: contact.phones.isNotEmpty
                          ? Text(contact.phones[0].number)
                          : null,
                    ),
                  );
                },
              );
            },
            error: (e, trace) => ErrorScreen(error: e.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
