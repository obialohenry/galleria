import 'package:galleria/src/config.dart';
import 'package:galleria/src/model.dart';
import 'package:hive/hive.dart';

class PhotosLocalDb {
  Box<PhotoModel> get _box => Hive.box<PhotoModel>(AppStrings.boxName);

  Future<void> savePhoto(PhotoModel photo) async {
    try {
      await _box.put(photo.localPath, photo);
      print("Successfully saved photo to hive.");
    } catch (e, s) {
      print("An error occured: $e at\n$s");
    }
  }

  List<PhotoModel> getAllPhotos() {
    try {
      print("photos: ${_box.values.toList()}");
      return _box.values.toList();
    } catch (e, s) {
      print("An error occured: $e at\n$s");
      return [];
    }
  }

  ///Returns a List of the keys' unique to stored photo models in the app.
  List<dynamic> getAllPhotoKeys() {
    try {
      print("photos Keys: ${_box.keys.toList()}");
      return _box.keys.toList();
    } catch (e, s) {
      print("An error occured: $e at\n$s");
      return [];
    }
  }

  Future<void> deletePhotos(List<dynamic> keys) async {
    await _box.deleteAll(keys);
  }
}
