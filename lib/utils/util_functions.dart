import 'dart:io';

import 'package:gallery_saver_plus/gallery_saver.dart';

class UtilFunctions {
  static Future<bool> saveImageToDeviceGallery({
    required File file,
    String albumName = 'Galleria',
  }) async {
    return await GallerySaver.saveImage(file.path, albumName: albumName) ?? false;
  }
}
