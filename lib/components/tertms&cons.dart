import 'package:flutter/material.dart';

class Terms {
  static void mostrarModalTerminos(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // obliga a aceptar o cerrar
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Términos y Condiciones"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Finalidad del tratamiento de datos',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Los datos personales recopilados por la aplicación serán utilizados exclusivamente para la prestación del servicio, análisis estadístico, mejoras del rendimiento, desarrollo de modelos de ciencia de datos y optimización de funcionalidades.\n',
                ),
                Text(
                  'Tipos de datos recopilados',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  'La aplicación podrá recoger datos identificativos proporcionados por el usuario, datos técnicos del dispositivo, datos de uso, así como información generada por la interacción con las funcionalidades del sistema.\n',
                ),
                Text(
                  'Base legal del tratamiento',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  'El tratamiento de datos se realizará conforme al consentimiento explícito del usuario, así como a la necesidad de procesar dichos datos para el cumplimiento de la relación contractual establecida con la aplicación.\n',
                ),
                Text(
                  'Tratamiento con fines de ciencia de datos',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  'La información recopilada podrá ser anonimizada o pseudonimizada y utilizada para la creación de modelos predictivos, segmentación, estudios estadísticos y otros procesos propios de la ciencia de datos destinados a mejorar la calidad del servicio.\n',
                ),
                Text(
                  'Medidas de seguridad',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  'El responsable del tratamiento implementará medidas técnicas y organizativas razonables para garantizar la protección de los datos frente a accesos no autorizados, pérdida, destrucción o alteración indebida.\n',
                ),
                Text(
                  'Cesión y transferencia de datos',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Los datos personales no serán vendidos ni transferidos a terceros, salvo cuando sea estrictamente necesario para la prestación del servicio, exista obligación legal o se realicen bajo mecanismos seguros de anonimización.\n',
                ),
                Text(
                  'Derechos del usuario',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  'El usuario podrá ejercer sus derechos de acceso, rectificación, supresión, oposición, limitación del tratamiento y portabilidad de los datos enviando una solicitud formal al correo o canal habilitado por el responsable del tratamiento.\n',
                ),
                Text(
                  'Retención de los datos',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Los datos serán conservados únicamente durante el tiempo necesario para cumplir con las finalidades del servicio. Los datos utilizados para fines analíticos podrán conservarse de forma anonimizada por un periodo mayor sin que permitan la identificación del usuario.\n',
                ),
                Text(
                  'Consentimiento y revocación',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  'El usuario podrá retirar su consentimiento en cualquier momento. La revocación no afectará la legalidad del tratamiento realizado con anterioridad.\n',
                ),
                Text(
                  'Modificaciones de la política',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  'El responsable del tratamiento podrá actualizar los presentes términos cuando sea necesario. Los cambios serán comunicados al usuario y su uso continuado de la aplicación constituirá la aceptación de las modificaciones.\n',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
