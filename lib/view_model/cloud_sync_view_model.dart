import 'dart:async';
import 'dart:io';
import 'package:galleria/config/app_images.dart';
import 'package:galleria/src/config.dart';
import 'package:galleria/src/package.dart';
import 'package:galleria/src/view_model.dart';
import 'package:galleria/utils/enums.dart';
import 'package:galleria/utils/util_functions.dart';
import 'package:galleria/view/components/app_text.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

final cloudSyncViewModel = NotifierProvider.autoDispose<CloudSyncViewModel, PhotoSyncState>(
  CloudSyncViewModel.new,
);

class CloudSyncViewModel extends Notifier<PhotoSyncState> {
  // double _uploadProgress = 0.0;
  String _errorMessage = '';
  @override
  build() {
    return PhotoSyncState.idle;
  }

  ///Compresses a photo file.
  ///
  ///parameter; file: The File object to be compressed.
  ///
  ///This method compresses a file to 1280x720, and saves the compressed image temporarily on the device
  ///in a timestamp-based naming format.
  ///It then return the compressed file when successful, or a null value when the process fails.
  Future<File?> compressPhoto(File file) async {
    debugPrint("COMPRESSING: ${file.path}");
    debugPrint("File exists: ${file.existsSync()}");

    final tempDir = await getTemporaryDirectory();
    debugPrint("Temp directory: ${tempDir.path}");
    final targetPath = "${tempDir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg";
    debugPrint("Target path: $targetPath");
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: 1280,
      minHeight: 720,
      quality: AppConstants.kCompressionQuality,
    );
    debugPrint("Compression result: ${result?.path ?? 'NULL'}");
    if (result != null) {
      File compressedFile = File(result.path);
      debugPrint("Original File: ${file.lengthSync()}");
      debugPrint("Compressed File: ${compressedFile.lengthSync()}");
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

      // uploadingPhoto.snapshotEvents.listen((TaskSnapshot snapshot) {
      //   // Calculate progress
      //   _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
      //   state = PhotoSyncState.uploading;
      // });
      await uploadingPhoto;
      downloadUrl = await photosRef.getDownloadURL();
      await file.delete();
      return downloadUrl;
    } on FirebaseException catch (e) {
      await file.delete();
      _errorMessage = _uploadExceptions(e.code);
      debugPrint("Firebase error: ${e.code} - ${e.message}");
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
  Future<void> syncPhoto(
    BuildContext context, {
    required File file,
    required String photoId,
  }) async {
    try {
      syncProcessDialog(context);

      final isDeviceConnectedToInternet = await UtilFunctions.isDeviceConnectedToNetwork();
      if (!isDeviceConnectedToInternet) {
        _errorMessage = AppStrings.checkYourInternetConnection;
        state = PhotoSyncState.error;
        return;
      }

      //Compressing photo.
      state = PhotoSyncState.compressing;
      final compressedPhoto = await compressPhoto(file);
      if (compressedPhoto == null) {
        _errorMessage = AppStrings.failedToCompressPhoto;
        state = PhotoSyncState.error;
        return;
      }

      //Uploading photo to cloud.
      state = PhotoSyncState.uploading;
      final downloadUrl = await uploadPhotoToCloud(compressedPhoto);
      debugPrint("DOWNLOAD URL: $downloadUrl");
      if (downloadUrl == null) {
        if (_errorMessage.isEmpty) {
          _errorMessage = AppStrings.failedToUploadToCloud;
        }
        state = PhotoSyncState.error;
        return;
      }

      //Success
      state = PhotoSyncState.success;
      debugPrint("PHOTO SYNCED SUCCESSFULLY");
      final updatedPhoto = ref
          .read(photosViewModel.notifier)
          .updateAPhoto(photoId: photoId, cloudReferenceId: downloadUrl);
      await PhotosLocalDb().updateAPhotoInLocalDb(updatedPhoto);
    } catch (e) {
      _errorMessage = e.toString();
      state = PhotoSyncState.error;
    }
  }

  /// Returns the feedback dialog title for each sync process state.
  ///
  /// Sync states includes; idle, compressing, uploading, success, error.
  String _syncStateTitle(PhotoSyncState syncState) {
    return switch (syncState) {
      PhotoSyncState.idle => "",
      PhotoSyncState.compressing => AppStrings.compressingPhoto,
      PhotoSyncState.uploading => AppStrings.uploadingToCloud,
      PhotoSyncState.success => AppStrings.photoSyncedSuccessfully,
      PhotoSyncState.error => AppStrings.syncFailed,
    };
  }

  /// Returns the feedback dialog content for each sync process state.
  ///
  /// Sync states includes; idle, compressing, uploading, success, error.
  Widget _syncProcessContent(PhotoSyncState syncState, BuildContext context) {
    return switch (syncState) {
      PhotoSyncState.idle => AppText(
        text: AppStrings.checkingInternetConnection,
        color: AppColors.kContentAlert,
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
      PhotoSyncState.compressing => Column(
        children: [
          SizedBox(height: 50),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.kBackgroundPrimary),
          ),
        ],
      ),
      PhotoSyncState.uploading => Column(
        children: [
          SizedBox(height: 50),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.kBackgroundPrimary),
          ),
        ],
      ),
      PhotoSyncState.success => Column(
        children: [
          Image(image: AssetImage(AppImages.successIcon)),
          SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.kSuccess,
              ),
              child: AppText(
                text: AppStrings.okay,
                color: AppColors.kPrimaryPressed,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      PhotoSyncState.error => Column(
        children: [
          Image(image: AssetImage(AppImages.errorIcon)),
          SizedBox(height: 10),
          AppText(
            text: _errorMessage,
            color: AppColors.kContentAlert,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          SizedBox(height: 25),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.kSuccess,
                ),
                child: AppText(
                  text: AppStrings.okay,
                  color: AppColors.kPrimaryPressed,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    };
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

  void syncProcessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final syncState = ref.watch(cloudSyncViewModel);
            return Center(
              child: Dialog(
                backgroundColor: AppColors.kSurfaceAlert,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        AppText(
                          text: _syncStateTitle(syncState),
                          color: AppColors.kContentAlert,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: 20),
                        _syncProcessContent(syncState, context),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

