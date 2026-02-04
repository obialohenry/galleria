import 'dart:io';
import 'package:galleria/config/app_images.dart';
import 'package:galleria/src/config.dart';
import 'package:galleria/src/package.dart';
import 'package:galleria/src/view_model.dart';
import 'package:galleria/utils/alert.dart';
import 'package:galleria/utils/enums.dart';
import 'package:galleria/view/components/app_text.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

final cloudSyncViewModel = NotifierProvider<CloudSyncViewModel, PhotoSyncState>(
  CloudSyncViewModel.new,
);

class CloudSyncViewModel extends Notifier<PhotoSyncState> {
  double _uploadProgress = 0.0;
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

  ///Uploads a photo to cloud storage, returning a downloadable URL.
  ///
  ///parameter; file: The compressed file to be uploaded.
  ///
  ///This method creates a FirebaseStorage reference, and a reference to a specific file path within that storage.
  ///It then uploads the specific file in the storage, while tracking the upload progress, after which it
  ///returns a downloadable URL for the stored file, and deletes the temporary stored compressed file on successful completion.
  ///It catches and throws an Exception, if any.
  Future<String?> uploadPhotoToCloud(File file) async {
    String? downloadUrl;
    // Create a storage reference from our app
    final storageRef = FirebaseStorage.instance.ref();
    // Create a reference to 'photos/{user_id}/dummy_image.jpg'
    final photosRef = storageRef.child("photos/${DummyData.userId}/${path.basename(file.path)}");

    try {
      final uploadingPhoto = photosRef.putFile(file);

      uploadingPhoto.snapshotEvents.listen((TaskSnapshot snapshot) {
        // Calculate progress
        _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
      });
      await uploadingPhoto;
      downloadUrl = await photosRef.getDownloadURL();
      // Upload successful, delete the temporary file
      await file.delete();
    } on FirebaseException catch (e) {
      _uploadExceptions(e.code);
    } catch (e, s) {
      throw ("An error occurred during upload $e at $s");
    }
    return downloadUrl;
  }

  Future<void> syncPhoto(
    BuildContext context, {
    required File file,
    required String photoId,
  }) async {
    try {
      final String? photoCloudReference;
      //Compressing photo.
      state = PhotoSyncState.compressing;
      //Syncing process dialog.
      syncProcessDialog(context, title: _syncStateTitle(), content: _syncProcessContent());
      final compressedPhoto = await compressPhoto(file);

      if (compressedPhoto != null) {
        //Uploading photo to cloud.
        state = PhotoSyncState.uploading;
        photoCloudReference = await uploadPhotoToCloud(compressedPhoto);

        if (photoCloudReference != null) {
          //Success
          state = PhotoSyncState.success;
          print("PHOTO SYNCED SUCCESSFULLY");
          final photo = ref
              .read(photosViewModel.notifier)
              .updateAPhoto(photoId: photoId, cloudReferenceId: photoCloudReference);
          PhotosLocalDb().updateAPhotoInLocalDb(photo);

          //Pops off loading dialog
          Future.delayed(Duration(milliseconds: 100), () {
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          });

          ///`OR`
          //TODO: SHOW SUCCESS TOAST TO USER.
        }
      }
    } catch (e) {
      state = PhotoSyncState.error;
      _errorMessage = e.toString();
      print(e);

      //Pops off loading dialog
      Future.delayed(Duration(milliseconds: 400), () {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      });

      ///`OR`
      //TODO: SHOW FAILURE TOAST TO USER.
    }
  }

  String _syncStateTitle() {
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

  Widget _syncProcessContent() {
    Widget content = switch (state) {
      PhotoSyncState.idle => const SizedBox.shrink(),
      PhotoSyncState.compressing => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.kBackgroundPrimary),
        ),
      ),
      PhotoSyncState.uploading => Center(
        child: CircularProgressIndicator(
          value: _uploadProgress,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.kBackgroundPrimary),
        ),
      ),
      PhotoSyncState.success => Image(image: AssetImage(AppImages.successIcon)),
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
        ],
      ),
    };
    return content;
  }

  void _uploadExceptions(String error) {
    switch (error) {
      case 'storage/unauthorized':
        throw ("You don't have permission to upload");
      case 'storage/unknown':
        throw ("Upload failed. Check your internet connection");
      case 'storage/quota-exceeded':
        throw ("Storage limit reached");
      case 'storage/invalid-checksum':
        throw ("File corrupted during upload");
      case 'storage/retry-limit-exceeded':
        throw ("Too many retries, likely network issue");
      default:
        throw ("An error occurred on Firebase $error");
    }
  }
}
