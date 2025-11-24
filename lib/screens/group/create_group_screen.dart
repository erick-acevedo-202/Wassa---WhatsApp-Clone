import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wasaaaaa/screens/group/group_controller.dart';
import 'package:wasaaaaa/screens/group/selected_contact.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  File? _image;
  TextEditingController conGroupName = TextEditingController();

  void createGroup() {
    if (conGroupName.text.trim().isNotEmpty && _image != null) {
      ref.read(groupControllerProvider).createGroup(context,
          conGroupName.text.trim(), _image!, ref.read(selectedGroupContacts));
      ref.read(selectedGroupContacts.notifier).state = [];
      Navigator.pop(context);
    }
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
      controller: conGroupName,
      decoration: InputDecoration(hintText: 'Nombre *'),
      keyboardType: TextInputType.name,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Grupo'),
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
                    Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.all(15),
                      child: Text(
                        'Agregar miembros',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    SelectedContact()
                  ]))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createGroup();
        },
        child: const Icon(Icons.done),
      ),
    );
  }
}
