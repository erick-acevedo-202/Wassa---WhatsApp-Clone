import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/models/userDAO.dart';
import 'package:wasaaaaa/screens/register/auth_number.dart';

final authControllerProvider = Provider((ref) {
  final authNumber = ref.watch(AuthNumberProvider);
  return AuthController(authNumber: authNumber, ref: ref);
});

final userDataProvider = FutureProvider((ref) {
  final authControler = ref.watch(AuthNumberProvider);
  return authControler.getUserData();
});

class AuthController {
  final AuthNumber authNumber;
  final Ref ref;

  AuthController({required this.authNumber, required this.ref});
  void singInWithNumber(BuildContext context, String Number) {
    authNumber.singInWithNumber(context, Number);
  }

  void verifyCode(BuildContext context, String verId, String code) {
    authNumber.verifyCode(context: context, verId: verId, code: code);
  }

  void saveUserInfo({
    required BuildContext context,
    required String name,
    required String email,
    required File? image,
    required String? description,
  }) {
    authNumber.saveUserInfo(
      context: context,
      name: name,
      email: email,
      image: image,
      description: description,
      ref: ref,
    );
  }

  Future<UserDAO?> getUserData() async {
    return await authNumber.getUserData();
  }

  Stream<UserDAO> streamUserData(String uid) {
    return authNumber.streamUserData(uid);
  }
}
