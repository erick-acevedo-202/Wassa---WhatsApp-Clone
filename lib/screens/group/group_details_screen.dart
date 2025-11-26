import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/models/userDAO.dart';
import 'package:wasaaaaa/screens/group/group_controller.dart';
import 'package:wasaaaaa/screens/select_contacts/select_contact_controller.dart';

class GroupDetailsScreen extends ConsumerStatefulWidget {
  const GroupDetailsScreen({super.key});

  @override
  ConsumerState<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

bool hide_nums = false;

class _GroupDetailsScreenState extends ConsumerState<GroupDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String groupId = args['groupId'] ?? '';
    final String groupName = args['groupName'] ?? '';
    final String groupImage = args['groupImage'] ?? '';

    return Scaffold(
        appBar: AppBar(
            title: Text(
              groupName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            actions: [
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'hide_num') {
                    setState(() {
                      hide_nums = !hide_nums;
                      print('hide nums ${hide_nums}');
                    });
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'hide_num',
                    child: Text('Ocultar Números'),
                  ),
                ],
              )
            ]),
        body: Align(
            alignment: Alignment.center,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(groupImage),
                    radius: 60,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.all(15),
                    child: Text(
                      'Miembros',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: FutureBuilder<List<UserDAO>>(
                      future: ref
                          .read(groupControllerProvider)
                          .getGroupMembers(groupId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              "Error al cargar miembros",
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          );
                        }

                        final members = snapshot.data!;

                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            final user = members[index];

                            return ListTile(
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundImage: user.profilePic.isNotEmpty
                                    ? CachedNetworkImageProvider(
                                        user.profilePic)
                                    : null,
                                backgroundColor: Colors.grey[400],
                                child: user.profilePic.isEmpty
                                    ? Text(
                                        user.name.isNotEmpty
                                            ? user.name[0].toUpperCase()
                                            : "?",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      )
                                    : null,
                              ),
                              title: Text(
                                user.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              subtitle:
                                  hide_nums ? null : Text(user.phoneNumber),
                              trailing: user.isOnline
                                  ? Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : null,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ])));
  }
}
