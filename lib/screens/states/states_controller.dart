import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/models/stateDAO.dart';
import 'package:wasaaaaa/screens/states/states_managment.dart';

final stateControllerProvider = Provider((ref) {
  final stateNumber = ref.watch(StatesManagmentProvider);
  return StatesController(statesManagment: stateNumber, ref: ref);
});

class StatesController {
  final StatesManagment statesManagment;
  final Ref ref;

  StatesController({required this.statesManagment, required this.ref});

  void createState({
    required BuildContext context,
    required String message,
    required String expiration,
    required String? extension,
    File? media,
  }) {
    statesManagment.createState(
        context: context,
        message: message,
        expiration: expiration,
        extension: extension,
        media: media,
        ref: ref);
  }

  Future<List<StateDAO>> getStatesForUser() async {
    return await statesManagment.getStatesForUser();
  }

  Future<void> deleteState(StateDAO state) async {
    return await statesManagment.deleteState(state);
  }

  Stream<List<StateDAO>> getStatesForChatContacts() {
    return statesManagment.getStatesForChatContacts();
  }
}
