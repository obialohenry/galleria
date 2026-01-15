import 'dart:io';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:intl/intl.dart';

class UtilFunctions {
  static Future<bool> saveImageToDeviceGallery({
    required File file,
    String albumName = 'Galleria',
  }) async {
    return await GallerySaver.saveImage(file.path, albumName: albumName) ?? false;
  }

  static String formatDate(DateTime dateTime, {String pattern = 'MM/dd/yyyy'}) {
    final formattedDate = DateFormat(pattern).format(dateTime);
    return formattedDate;
  }

  static String formatTime(DateTime dateTime, {String pattern = "Hm"}) {
    final formattedTime = DateFormat(pattern).format(dateTime);
    return formattedTime;
  }
}
