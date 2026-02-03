import 'dart:io';
import 'package:galleria/src/config.dart';
import 'package:galleria/src/package.dart';
import 'package:galleria/src/view_model.dart';
import 'package:galleria/utils/alert.dart';
import 'package:galleria/utils/enums.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

final cloudSyncViewModel = NotifierProvider<CloudSyncViewModel, PhotoSyncState>(
  CloudSyncViewModel.new,
);

class CloudSyncViewModel extends Notifier<PhotoSyncState> {
  @override
  build() {
    return PhotoSyncState.idle;
  }

  ///Compresses a photo file.
  ///
  ///parameters:
  ///- file: The File object to be compressed.
  ///
  ///This method compresses a file to 1280x720, and saves the compressed image temporarily on the device
  ///in a timestamp-based naming format.
  ///It then return the compressed file when successful, or a null value when the process fails.
  Future<File?> compressPhoto(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = "$tempDir/photo_${DateTime.now().millisecondsSinceEpoch}.jpg";
    File? compressedFile;
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: 1280,
        minHeight: 720,
        quality: 88,
      );
      if (result != null) {
        compressedFile = File(result.path);
        print("Original File: ${file.lengthSync()}");
        print("Compressed File: ${compressedFile.lengthSync()}");
      }
    } catch (e, s) {
      throw ("An error occurred during compression $e at $s");
    }

    return compressedFile;
  }

  Future<void> uploadPhotoToCloud(File file) async {
    // Create a storage reference from our app
    final storageRef = FirebaseStorage.instance.ref();
    // Create a reference to 'images/mountains.jpg'
    final photosRef = storageRef.child("photos/${DummyData.userId}/${path.basename(file.path)}");

    try {
      await photosRef.putFile(file);
    } on FirebaseException catch (e, s) {
      throw ("An error occurred on Firebase $e at $s");
    } catch (e, s) {
      throw ("An error occurred during upload $e at $s");
    }
  }

  Future<void> syncPhoto(
    BuildContext context, {
    required File file,
    required String photoId,
  }) async {
    try {
      //Compressing photo.
      state = PhotoSyncState.compressing;
      syncProcessDialog(context, title: syncStateTitle());
      final compressedPhoto = await compressPhoto(file);

      //Uploading photo to cloud.
      if (compressedPhoto != null) {
        state = PhotoSyncState.uploading;
        await uploadPhotoToCloud(compressedPhoto);
      }

      //Success
      state = PhotoSyncState.success;
      print("PHOTO SYNCED SUCCESSFULLY");
      final photo = ref
          .read(photosViewModel.notifier)
          .updateAPhoto(photoId: photoId, cloudReferenceId: "");
      PhotosLocalDb().updateAPhotoInLocalDb(photo);

      //Pops off loading dialog
      Future.delayed(Duration(milliseconds: 100), () {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      });

      ///`OR`
      //TODO: SHOW SUCCESS TOAST TO USER.
    } catch (e) {
      state = PhotoSyncState.error;
      print(e);

      //Pops off loading dialog
      Future.delayed(Duration(milliseconds: 100), () {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      });

      ///`OR`
      //TODO: SHOW FAILURE TOAST TO USER.
    }
  }

  String syncStateTitle() {
    String message = switch (state) {
      PhotoSyncState.compressing => AppStrings.compressingPhoto,
      PhotoSyncState.uploading => AppStrings.uploadingToCloud,
      PhotoSyncState.success => AppStrings.photoSyncedSuccessfully,
      PhotoSyncState.error => AppStrings.syncFailed,
      _ => "",
    };
    return message;
  }

  Color syncButtonColor() {
    Color buttonColor = switch (state) {
      PhotoSyncState.idle || PhotoSyncState.error => AppColors.kPrimary,
      PhotoSyncState.compressing || PhotoSyncState.uploading => AppColors.kPending,
      PhotoSyncState.success => AppColors.kSuccess,
    };
    return buttonColor;
  }

  String syncButtonActionText() {
    String text = switch (state) {
      PhotoSyncState.idle || PhotoSyncState.error => AppStrings.syncPhoto,
      PhotoSyncState.compressing => AppStrings.syncPhoto,
      PhotoSyncState.uploading => AppStrings.syncPhoto,
      PhotoSyncState.success => AppStrings.synced,
    };
    return text;
  }
}
