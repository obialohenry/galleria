import 'dart:async';
import 'dart:io';
import 'package:galleria/model/local/photo_sync_state.dart';
import 'package:galleria/src/config.dart';
import 'package:galleria/src/package.dart';
import 'package:galleria/src/view_model.dart';
import 'package:galleria/utils/enums.dart';
import 'package:galleria/utils/util_functions.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

final cloudSyncViewModel = NotifierProvider.autoDispose<CloudSyncViewModel, PhotoSyncState>(
  CloudSyncViewModel.new,
);

class CloudSyncViewModel extends Notifier<PhotoSyncState> {
  String? _errorMessage;
  @override
  build() {
    return PhotoSyncState();
  }

  ///Compresses a photo file.
  ///
  ///parameter; file: The File object to be compressed.
  ///
  ///This method compresses a file to 1280x720, and saves the compressed image temporarily on the device
  ///in a timestamp-based naming format.
  ///It then return the compressed file when successful, or a null value when the process fails.
  Future<File?> compressPhoto(File file) async {

    final tempDir = await getTemporaryDirectory();
    final targetPath = "${tempDir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: 1280,
      minHeight: 720,
      quality: AppConstants.kCompressionQuality,
    );
    if (result != null) {
      File compressedFile = File(result.path);
      return compressedFile;
    } else {
      debugPrint("Compression returned null");
      return null;
    }
  }

  ///Uploads a photo to cloud storage, returning a downloadable URL.
  ///
  ///parameter; file: The compressed file to be uploaded.
  ///
  ///This method creates a FirebaseStorage reference, and a reference to a specific file path within that storage.
  ///It then uploads the specific file in the storage, after which it
  ///returns a downloadable URL for the stored file, and deletes the temporary stored compressed file on successful completion.
  ///It catches and throws an exceptions on Firebase.
  Future<String?> uploadPhotoToCloud(File file) async {
    String? downloadUrl;
    // Create a storage reference from our app
    final storageRef = FirebaseStorage.instance.ref();
    // Create a reference to 'photos/{user_id}/dummy_image.jpg'
    final photosRef = storageRef.child("photos/${DummyData.userId}/${path.basename(file.path)}");

    try {
      //Tells Firebase and browser that this is a JPEG image.
      final metadata = SettableMetadata(contentType: 'image/jpeg');

      final uploadingPhoto = photosRef.putFile(file, metadata);
      await uploadingPhoto;
      downloadUrl = await photosRef.getDownloadURL();
      await file.delete();
      return downloadUrl;
    } on FirebaseException catch (e) {
      await file.delete();
      _errorMessage = _uploadExceptions(e.code);
      return null;
    }
  }

  ///Sync a photo file to the cloud.
  ///
  ///parameters:
  ///- file: Photo file to be compressed and uploaded to Firebase storage.
  ///- photoId: Unique id of the photo object.
  ///
  ///This method starts the syncing process by compressing the photo file using the `compressPhoto` method,
  ///after which it then uploads the photo file to Firebase cloud storage using the `uploadPhotoToCloud` method.
  ///The entire sync process is properly communicated to the user, using a dialog display.
  ///Each process handles failure state by displaying an error message and stoping the entire sync process.
  ///When successfull, a cloud reference URL for the photo file will be displayed on screen, and the photo object metadata
  ///will be updated at both runtime and on the device local storage.
  Future<void> syncPhoto({
    required File file,
    required String photoId,
  }) async {
    try {

      final isDeviceConnectedToInternet = await UtilFunctions.isDeviceConnectedToNetwork();
      if (!isDeviceConnectedToInternet) {
        state = state.withChanges(
          status: PhotoSyncStatus.error,
          errorMessage: AppStrings.checkYourInternetConnection,
        );
        return;
      }

      //Compressing photo.
      state = state.withChanges(status: PhotoSyncStatus.compressing);
      final compressedPhoto = await compressPhoto(file);
      if (compressedPhoto == null) {
        state = state.withChanges(
          status: PhotoSyncStatus.error,
          errorMessage: AppStrings.failedToCompressPhoto,
        );
        return;
      }

      //Uploading photo to cloud.
      state = state.withChanges(status: PhotoSyncStatus.uploading);
      final downloadUrl = await uploadPhotoToCloud(compressedPhoto);
      if (downloadUrl == null) {
        state = state.withChanges(
          status: PhotoSyncStatus.error,
          errorMessage: _errorMessage ?? AppStrings.failedToUploadToCloud,
        );
        return;
      }

      //Success
      state = state.withChanges(status: PhotoSyncStatus.success);
      final updatedPhoto = ref
          .read(photosViewModel.notifier)
          .updateAPhoto(photoId: photoId, cloudReferenceId: downloadUrl);
      await PhotosLocalDb().updateAPhotoInLocalDb(updatedPhoto);
    } catch (e) {
      _errorMessage = e.toString();
      state = state.withChanges(status: PhotoSyncStatus.error, errorMessage: _errorMessage);
    }
  }

  String _uploadExceptions(String error) {
    return switch (error) {
      'storage/object-not-found' => "Upload path not found. Please try again",
      'storage/unauthorized' => "You don't have permission to upload",
      'storage/unknown' => "Upload failed. Check your internet connection",
      'storage/quota-exceeded' => "Storage limit reached",
      'storage/invalid-checksum' => "File corrupted during upload",
      'storage/retry-limit-exceeded' => "Too many retries, likely network issue",
      _ => "An error occurred on Firebase $error",
    };
  }
}

