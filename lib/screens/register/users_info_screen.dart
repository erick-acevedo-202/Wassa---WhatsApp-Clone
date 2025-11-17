import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wasaaaaa/screens/register/auth_controller.dart';

class UsersInfoScreen extends ConsumerStatefulWidget {
  const UsersInfoScreen({super.key});

  @override
  ConsumerState<UsersInfoScreen> createState() => _UsersInfoScreenState();
}

class _UsersInfoScreenState extends ConsumerState<UsersInfoScreen> {
  File? _image;
  TextEditingController conName = TextEditingController();
  TextEditingController conEmail = TextEditingController();
  TextEditingController conDescription = TextEditingController();

  bool get validData {
    final name = conName.text.trim();
    final email = conEmail.text.trim();

    final nameOk = RegExp(r'^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ ]{3,}$').hasMatch(name);
    final emailOk = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email);

    return nameOk && emailOk;
  }

  Future<void> pickAndCropImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Ajustar imagen',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          hideBottomControls: true,
        ),
        IOSUiSettings(
          title: 'Ajustar imagen',
          aspectRatioPickerButtonHidden: true,
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _image = File(croppedFile.path);
      });
    }
  }

  Future<void> takeAndCropImage() async {
    final picker = ImagePicker();

    // Tomar foto desde la cámara
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    // Recortar la imagen
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Ajustar imagen',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          hideBottomControls: true,
        ),
        IOSUiSettings(
          title: 'Ajustar imagen',
          aspectRatioPickerButtonHidden: true,
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _image = File(croppedFile.path);
      });
    }
  }

  void _showImageSourceMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  takeAndCropImage(); // función para cámara
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Elegir desde galería'),
                onTap: () {
                  Navigator.pop(context);
                  pickAndCropImage(); // función para galería
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final btnImage = GestureDetector(
      onTap: () {
        _showImageSourceMenu(context);
      },
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[300],
        backgroundImage: _image != null ? FileImage(_image!) : null,
        child: _image == null
            ? const Icon(Icons.camera_alt, size: 30, color: Colors.black54)
            : null,
      ),
    );

    final txtName = TextField(
      controller: conName,
      decoration: InputDecoration(hintText: 'Nombre *'),
      keyboardType: TextInputType.name,
    );
    final txtEmail = TextField(
      controller: conEmail,
      decoration: InputDecoration(hintText: 'Correo *'),
      keyboardType: TextInputType.emailAddress,
    );
    final txtDescription = TextField(
      controller: conDescription,
      decoration: InputDecoration(hintText: 'Descripción'),
      keyboardType: TextInputType.name,
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
        title: Text('Información del usuario'),
      ),
      body: SafeArea(
          child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            btnImage,
            SizedBox(
              height: 15,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * .7,
              child: txtName,
            ),
            SizedBox(
              height: 15,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * .7,
              child: txtEmail,
            ),
            SizedBox(
              height: 15,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * .7,
              child: txtDescription,
            ),
            SizedBox(
              height: 15,
            ),
            btnSave,
          ],
        ),
      )),
    );
  }

  void _showConfirm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(validData ? 'Confirmar' : 'Revisa tu información'),
          content: SingleChildScrollView(
            child: validData
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Revisa tu información antes de continuar.'),
                      SizedBox(height: 15),
                      Text('Nombre: ${conName.text}'),
                      SizedBox(height: 8),
                      Text('Email: ${conEmail.text}'),
                      SizedBox(height: 8),
                      Text(
                          'Descripción: ${conDescription.text.isEmpty ? '(vacío)' : conDescription.text}'),
                      SizedBox(height: 20),
                      Text('¿Es correcta la información?'),
                    ],
                  )
                : Column(children: [
                    Text('Necesitas llenar el campo de nombre y email.'),
                  ]),
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
                      Navigator.of(context).pop(); // Cerrar el diálogo

                      // Llamas tu método de guardar
                      ref.read(authControllerProvider).saveUserInfo(
                            context: context,
                            name: conName.text.trim(),
                            email: conEmail.text.trim(),
                            description: conDescription.text.trim(),
                            image: _image,
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
