import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController conCode = TextEditingController();

  bool get codeLenght {
    return conCode.text.length == 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verificar tu código')),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Te hemos enviado un código.'),
          TextField(
            controller: conCode,
            decoration: InputDecoration(hintText: '- - - - - -'),
            inputFormatters: [
              LengthLimitingTextInputFormatter(6),
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ],
      ),
    );
  }
}
