import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/screens/register/auth_number.dart';

final authControllerProvider = Provider((red) {
  final authNumber = red.watch(AuthNumberProvider);
  return AuthController(authNumber: authNumber);
});

class AuthController {
  final AuthNumber authNumber;

  AuthController({required this.authNumber});
  void singInWithNumber(BuildContext context, String Number) {
    authNumber.singInWithNumber(context, Number);
  }
}
