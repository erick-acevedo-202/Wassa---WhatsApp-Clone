import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final FirabaseStorageRepoProvider = Provider((ref) {
  return FirabaseStorageRepo(firebaseStorage: FirebaseStorage.instance);
});

class FirabaseStorageRepo {
  final FirebaseStorage firebaseStorage;

  FirabaseStorageRepo({
    required this.firebaseStorage,
  });

  Future<String> storeFile({required String ref, required File file}) async {
    UploadTask upload = firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot snapshot = await upload;
    String url = await snapshot.ref.getDownloadURL();
    return url;
  }
}
