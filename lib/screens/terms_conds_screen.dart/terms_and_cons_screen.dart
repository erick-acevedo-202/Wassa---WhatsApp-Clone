import 'package:flutter/material.dart';
import 'package:wasaaaaa/components/strings.dart';
import 'package:wasaaaaa/components/tertms&cons.dart';

class TermsAndConsScreen extends StatelessWidget {
  TermsAndConsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/LOGO-VERTICAL-TECNM.png'),
                ),
              ),
            ),
            Text(
              'Bienvenido a ${Strings.AppName}',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.1),

                Expanded(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        const TextSpan(text: 'Lee nuestros "'),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () {
                              Terms.mostrarModalTerminos(context);
                            },
                            child: const Text('Términos y condiciones'),
                          ),
                        ),
                        const TextSpan(
                          text: '". Presiona en "Acepto" para continuar.',
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: MediaQuery.of(context).size.width * 0.1),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * .1),

            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text(
                'Acepto.',
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
