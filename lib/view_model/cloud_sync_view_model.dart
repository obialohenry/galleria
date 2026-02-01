import 'dart:io';
import 'package:galleria/src/package.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

class CloudSyncViewModel {
  Future<void> uploadPhoto(File file) async {
    // Create a storage reference from our app
    final storageRef = FirebaseStorage.instance.ref();
    // Create a reference to 'images/mountains.jpg'
    final photosRef = storageRef.child("photos/${DummyData.userId}/${path.basename(file.path)}");

    try {
      await photosRef.putFile(file);
    } on FirebaseException catch (e, s) {
      print("An error occurred $e at $s");
    } catch (e, s) {
      print("An error occurred $e at $s");
    }
  }
}
