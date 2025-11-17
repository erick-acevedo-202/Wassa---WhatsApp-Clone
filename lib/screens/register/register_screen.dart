import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/components/strings.dart';
import 'package:wasaaaaa/screens/register/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  TextEditingController conNumber = TextEditingController();
  String countryCode = "MX";
  String dialCode = "+52";

  bool get correctLenght {
    return conNumber.text.length == 10;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Ingresa tu número de teléfono'),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${Strings.AppName} te enviara un mensaje SMS para verificar tu número de telefono. Ingresa tu número.',
              style: TextStyle(color: Colors.black, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Row(
              children: [
                CountryCodePicker(
                  initialSelection: countryCode,
                  onChanged: (code) {
                    setState(() {
                      dialCode = code.dialCode!;
                      countryCode = code.code!;
                    });
                  },
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  comparator: (a, b) => b.name!.compareTo(a.name!),
                  flagDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  onInit: (code) {
                    dialCode = code!.dialCode!;
                    countryCode = code.code!;
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: conNumber,
                    decoration: InputDecoration(hintText: 'número de telefono'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ],
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
                _showConfirm();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(correctLenght ? 'Confirmar' : 'Revisa tu número'),
          content: SingleChildScrollView(
            child: correctLenght
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Verifiquemos tu número de teléfono.'),
                      SizedBox(height: 15),
                      Text('$dialCode${conNumber.text}'),
                      SizedBox(height: 15),
                      Text('¿Es correcto?'),
                    ],
                  )
                : Column(children: [Text('Corrige tu número de teléfono.')]),
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
                      ref.read(authControllerProvider).singInWithNumber(
                            context,
                            '$dialCode${conNumber.text}',
                          );
                    },
                  )
                : SizedBox(),
          ],
        );
      },
    );
  }
}
