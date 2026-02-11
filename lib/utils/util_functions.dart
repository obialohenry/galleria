import 'dart:io';
import 'package:dio/dio.dart';
import 'package:galleria/src/config.dart';
import 'package:galleria/src/package.dart';
import 'package:galleria/view/components/app_text.dart';
import 'package:intl/intl.dart';

class UtilFunctions {
  static final Dio _dio = Dio();

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
  static Future<Position> determinePosition() async {
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
  static Future<String> determineAddress({
    required double latitude,
    required double longitude,
  }) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) return AppStrings.unknownLocation;

      final address = placemarks.first;
      final addressParts = [address.locality, address.administrativeArea, address.country];

      final filteredParts = addressParts.where((part) => part != null && part.isNotEmpty);
      final formattedAddress = filteredParts.join(", ");

      return formattedAddress.isNotEmpty ? formattedAddress : AppStrings.unknownLocation;
    } catch (e, s) {
      print("An error occured $e at\n$s");
      return AppStrings.unknownLocation;
    }
  }

  ///Scan album and return a list of images present.
  ///
  ///Scans through Galleria album on the phone using the photo_manager plugin.
  ///It returns an empty list based on the following conditions:
  ///- If the Galleria album have not yet been created on the device.
  ///- If on first app usage, user denies photo namager's request permission.
  ///Returns a list of image paths of available images in the devices's Galleria
  ///album when successful.
  static Future<List<String>> scanGalleriaAlbum() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    List<String> galleriaPhotoPaths;
    if (ps.isAuth || ps.hasAccess) {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList();

      AssetPathEntity? galleriaAlbum;
      try {
        galleriaAlbum = albums.firstWhere((album) => album.name == "Galleria");
      } catch (e, s) {
        galleriaAlbum = null;
        print("An error occured $e at $s");
      }

      //Most likely due to the album not haven been created on the device.
      if (galleriaAlbum == null) return [];

      final List<AssetEntity> photos = await galleriaAlbum.getAssetListPaged(page: 0, size: 100);
      final List<File?> photoFiles = await Future.wait(photos.map((photo) => photo.file));
      galleriaPhotoPaths = photoFiles
          .where((file) => file != null)
          .map((file) => file!.path.split('/').last)
          .toList();
    } else {
      //Permisson denied.
      galleriaPhotoPaths = [];
      PhotoManager.openSetting();
    }
    print("gallery photo Keys: $galleriaPhotoPaths");
    return galleriaPhotoPaths;
  }

  ///Delete PhotoModel objects in the db using it's keys
  ///
  ///parameters:
  ///- imagePaths: list of image path's in Galleria's album on the user's device.
  ///
  ///Gets the entire keys stored in hive's data base.
  ///Creates a new key list `keysToDelete`, stores key strings that are not
  ///in the Galleria's album on the device, and deletes the list of keys from hive's data base.
  ///Reconciling hive's data base with images present on the album.
  static void updateHiveDbBasedOnPhotosInGallery(List<String> imagePaths) {
    final photoKeys = PhotosLocalDb().getAllPhotoKeys();

    final keysToDelete = photoKeys
        .where((key) => !imagePaths.contains(key.split('/').last))
        .toList();
    PhotosLocalDb().deletePhotos(keysToDelete);
  }

  ///Handles anonymous authentication.
  ///
  ///Checks if user is already signed in, if so, stores the user id. And if
  ///a user isn't signed in, it signs the user in anonymously and stores the user id.
  static Future<void> anonymousAuth() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // User already signed in, use existing account
      DummyData.userId = currentUser.uid;
      debugPrint("Current user ID: ${DummyData.userId}");
    } else {
      // No user signed in, create anonymous account
      try {
        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        print("Signed in with temporary account.");

        final user = userCredential.user;
        if (user != null) {
          DummyData.userId = user.uid;
          debugPrint("User ID: ${DummyData.userId}");
        }
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "operation-not-allowed":
            print("Anonymous auth hasn't been enabled for this project.");
            break;
          default:
            print("Unknown error: ${e.code.toUpperCase()}");
        }
      }
    }
  }

  static void copyToClipBoard(BuildContext context, {required String value}) {
    Clipboard.setData(ClipboardData(text: value));

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.kSuccess,
        content: AppText(text: AppStrings.successfullyCopied, color: AppColors.kTextSecondary),
        duration: Duration(seconds: 2),
      ),
    );
  }

  static Future<bool> isDeviceConnectedToNetwork() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();

      if (connectivityResults.isEmpty ||
          connectivityResults.every((result) => result == ConnectivityResult.none)) {
        return false;
      }

      final response = await _dio.get(
        'https://clients3.google.com/generate_204',
        options: Options(
          method: 'HEAD',
          sendTimeout: Duration(seconds: 3),
          receiveTimeout: Duration(seconds: 3),
          validateStatus: (_) => true,
        ),
      );
      if (response.statusCode == 204) {
        return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }
}
