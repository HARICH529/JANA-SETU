import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadFile(File file, String path) async {
    try {
      var uuid = const Uuid().v4();
      final ref = _storage.ref().child('$path/$uuid');
      UploadTask uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => {});
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
