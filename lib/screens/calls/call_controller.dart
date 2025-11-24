import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/models/callDAO.dart';
import 'package:wasaaaaa/screens/calls/call_firebase.dart';

final callControllerProvider = Provider((ref) {
  final callFirebase = ref.watch(CallFirebaseProvider);
  return CallController(callFirebase: callFirebase, ref: ref);
});

final incomingCallStreamProvider = StreamProvider<CallDAO?>((ref) {
  return ref.read(callControllerProvider).listenLatestIncomingCall();
});

class CallController {
  final CallFirebase callFirebase;
  final Ref ref;

  CallController({required this.callFirebase, required this.ref});

  Future<String> createCall({
    required BuildContext context,
    required List<String> calleeIds,
    required String name,
  }) async {
    return await callFirebase.createCall(
      context: context,
      calleeIds: calleeIds,
      name: name,
    );
  }

  Future<void> updateCall(
      {required BuildContext context,
      required CallDAO call,
      required String answer}) async {
    await callFirebase.updateCall(context: context, call: call, answer: answer);
  }

  Stream<CallDAO?> listenLatestIncomingCall() {
    return callFirebase.listenLatestIncomingCall();
  }

  Stream<List<CallDAO>> listenCallHistory() {
    return callFirebase.listenCallHistory();
  }

  Future<String?> getUserNameById(String uid) async {
    return callFirebase.getUserNameById(uid);
  }
}
