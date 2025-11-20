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
  String? extension;

  bool get isValid {
    return conStory.text.isNotEmpty;
  }

  Future<void> pickMedia() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg', 'jpeg', 'png', 'gif', // imágenes
        'mp4', 'mov', 'avi', // videos
        'mp3', 'wav', 'm4a', 'flac', 'ogg', // música
      ],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);

      final ext = result.files.single.extension?.toLowerCase() ?? "";
      const maxSize = 25 * 1024 * 1024;
      final fileSize = await file.length();
      if (fileSize > maxSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("El archivo supera los 25 MB")),
        );
        return;
      }

      setState(() {
        _media = file;
        extension = ext;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final txtMessage = TextField(
      controller: conStory,
      maxLines: 4,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
      ),
    );

    final btnImage = ElevatedButton(
      onPressed: pickMedia,
      child:
          Text(_media != null ? 'Archivo seleccionado' : 'Seleccionar archivo'),
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
            SizedBox(
              height: 15,
            ),
            txtMessage,
            SizedBox(
              height: 15,
            ),
            btnImage,
            SizedBox(
              height: 15,
            ),
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
          title: Text(isValid ? 'Confirmar Story' : 'Revisa tu información'),
          content: SingleChildScrollView(
            child: isValid
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
            // Botón Aceptar SOLO si isValid es true
            isValid
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
                          extension: extension,
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
