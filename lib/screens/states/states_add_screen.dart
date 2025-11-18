import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasaaaaa/screens/states/states_controller.dart';

class StatesAddScreen extends ConsumerStatefulWidget {
  const StatesAddScreen({super.key});

  @override
  ConsumerState<StatesAddScreen> createState() => _StatesAddScreenState();
}

class _StatesAddScreenState extends ConsumerState<StatesAddScreen> {
  TextEditingController conStory = TextEditingController();
  File? _media;

  bool get isValid {
    return conStory.text.isNotEmpty;
  }

  Future<void> pickMedia() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg', 'jpeg', 'png', 'gif', // imágenes
        'mp4', 'mov', 'avi', // videos
        'mp3', 'wav', 'm4a', // música
      ],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _media = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final txtMessage = TextField(
      controller: conStory,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Escribe tu story',
        border: OutlineInputBorder(),
      ),
    );

    final btnImage = ElevatedButton(
      onPressed: pickMedia,
      child:
          Text(_media != null ? 'Archivo seleccionado' : 'Seleccionar archivo'),
    );

    final txtResult = Text(
      'Historia: ${conStory.text}\n'
      'Archivo seleccionado: ${_media?.path ?? 'Ninguno'}',
    );

    final btnSave = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        minimumSize: Size(200, 45),
      ),
      child: Text(
        "Guardar",
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: () {
        _showConfirm();
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar historia'),
      ),
      body: SafeArea(
          child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            txtMessage,
            SizedBox(
              height: 15,
            ),
            btnImage,
            SizedBox(
              height: 15,
            ),
            txtResult,
            SizedBox(
              height: 20,
            ),
            btnSave
          ],
        ),
      )),
    );
  }

  void _showConfirm() {
    bool validData = conStory.text.trim().isNotEmpty || _media != null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(validData ? 'Confirmar Story' : 'Revisa tu información'),
          content: SingleChildScrollView(
            child: validData
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Revisa tu historia antes de continuar.'),
                      SizedBox(height: 15),
                      Text(
                          'Historia: ${conStory.text.isEmpty ? "(vacío)" : conStory.text}'),
                      SizedBox(height: 8),
                      Text('Archivo: ${_media?.path ?? "(ninguno)"}'),
                      SizedBox(height: 20),
                      Text('¿Es correcta la información?'),
                    ],
                  )
                : Column(
                    children: [
                      Text('Necesitas escribir algo o seleccionar un archivo.'),
                    ],
                  ),
          ),
          actions: [
            ElevatedButton(
              child: Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // Botón Aceptar SOLO si validData es true
            validData
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
                      ref.read(stateControllerProvider).createState(
                          context: context,
                          media: _media,
                          message: conStory.text,
                          expiration: DateTime.now()
                              .add(Duration(days: 1))
                              .toIso8601String());
                    })
                : SizedBox(),
          ],
        );
      },
    );
  }
}
