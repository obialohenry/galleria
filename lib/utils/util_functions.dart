import 'dart:io';
import 'package:galleria/config/app_strings.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class UtilFunctions {
  ///Create an album name on device, and save a file image's path to the created album in the device.
  static Future<bool> saveImageToDeviceGallery({
    required File file,
    String albumName = 'Galleria',
  }) async {
    return await GallerySaver.saveImage(file.path, albumName: albumName) ?? false;
  }
  
  ///Return a formatted date in the pattern passed in as an argument.
  static String formatDate(DateTime dateTime, {String pattern = 'MM/dd/yyyy'}) {
    final formattedDate = DateFormat(pattern).format(dateTime);
    return formattedDate;
  }
 
  ///Return a formatted time in the pattern passed in as an argument.
  static String formatTime(DateTime dateTime, {String pattern = "Hm"}) {
    final formattedTime = DateFormat(pattern).format(dateTime);
    return formattedTime;
  }

  /// Determines the current position of the device.
  ///
  /// Throws a [LocationServiceDisabledException] or [PermissionDeniedException]
  /// when location services are unavailable or permissions are not granted.
  Future<Position> determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied. Please enable it from settings.');
    }

    const locationSettings = LocationSettings(accuracy: LocationAccuracy.medium);

    return Geolocator.getCurrentPosition(locationSettings: locationSettings);
  }

  /// Determines an address using a device position.
  ///
  /// Parameters:
  /// - latitude
  /// - longitude
  ///
  /// Get's a list of placemarks of that latitude and longitude,
  /// If the list is not empty store the first placemark item. return an "Uknown location" string if empty.
  /// From the stored placemark item, we get non-nullable string parts that make up an acceptable address,
  /// and if empty or reverse geocoding fails returns a the "Unknown location" placeholder.
  Future<String> determineAddress({required double latitude, required double longitude}) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) return AppStrings.unknownLocation;

      final address = placemarks.first;
      final addressParts = [
        address.street,
        address.locality,
        address.administrativeArea,
        address.country,
      ];

      final filteredParts = addressParts.where((part) => part != null && part.isNotEmpty);
      final formattedAddress = filteredParts.join(", ");

      return formattedAddress.isNotEmpty ? formattedAddress : AppStrings.unknownLocation;
    } catch (e, s) {
      print("An error occured $e at\n$s");
      return AppStrings.unknownLocation;
    }
  }
}
