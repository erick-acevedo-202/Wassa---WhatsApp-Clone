import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/screens/register/auth_controller.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  TextEditingController conCode = TextEditingController();

  bool get correctLenght {
    return conCode.text.length == 6;
  }

  bool get codeLenght {
    return conCode.text.length == 6;
  }

  @override
  Widget build(BuildContext context) {
    final verId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(title: Text('Verificar tu código')),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text('Te hemos enviado un código.'),
            SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * .5,
              child: TextField(
                controller: conCode,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: '- - - - - -',
                    hintStyle: TextStyle(fontSize: 26)),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(6),
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                minimumSize: Size(200, 45),
              ),
              child: Text(
                "Continuar",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {
                _showConfirm(verId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirm(String verId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(correctLenght ? 'Confirmar' : 'Revisa tu código'),
          content: SingleChildScrollView(
            child: correctLenght
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Verifiquemos tu número de código.'),
                      SizedBox(height: 15),
                      Text('${conCode.text}'),
                      SizedBox(height: 15),
                      Text('¿Es correcto?'),
                    ],
                  )
                : Column(children: [Text('Corrige tu código.')]),
          ),
          actions: [
            ElevatedButton(
              child: Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            correctLenght
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      "Aceptar",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    onPressed: () {
                      ref
                          .read(authControllerProvider)
                          .verifyCode(context, verId, conCode.text);
                    },
                  )
                : SizedBox(),
          ],
        );
      },
    );
  }
}
