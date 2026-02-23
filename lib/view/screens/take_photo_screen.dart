import 'dart:io';
import 'package:galleria/src/config.dart';
import 'package:galleria/src/model.dart';
import 'package:galleria/src/package.dart';
import 'package:galleria/src/screens.dart';
import 'package:galleria/src/view_model.dart';
import 'package:galleria/utils/util_functions.dart';
import 'package:galleria/view/components/app_text.dart';

class TakePhotoScreen extends ConsumerWidget {
  const TakePhotoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraState = ref.watch(cameraControllerProvider);
    final uiState = cameraState.value;
    final photosProvider = ref.watch(photosViewModel);
    return Scaffold(
      backgroundColor: AppColors.kBackgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            if (cameraState.isLoading)
              Expanded(
                flex: 3,
                child: Container(
                  color: Colors.transparent,
                  child: Center(child: CircularProgressIndicator(color: AppColors.kPrimary)),
                ),
              )
            else if (uiState is CameraReady)
              CameraPreview(uiState.controller)
            else if (uiState is CameraPermissionDenied)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.no_photography, color: AppColors.kInactiveColor, size: 20),
                  SizedBox(height: 15),
                  AppText(
                    text: AppStrings.cameraPermissionRequiredToTakePhotos,
                    color: AppColors.kTextSecondary,
                  ),
                ],
              )
            else if (uiState is CameraFailure)
              Expanded(
                flex: 2,
                child: Container(
                  color: AppColors.kPrimary,
                  child: Center(child: AppText(text: uiState.message)),
                ),
              ),
            Spacer(flex: 1),
            if (cameraState.hasValue && uiState is CameraReady)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  photosProvider.isEmpty
                      ? SizedBox(height: 45, width: 45)
                      : GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PhotoDetailsScreen(index: photosProvider.length - 1),
                              ),
                            );
                          },
                          child: Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: FileImage(File(photosProvider.last.localPath)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                  GestureDetector(
                    onTap: () async {
                      try {
                        final File? image = await ref
                            .read(cameraControllerProvider.notifier)
                            .takePicture();
                        if (image != null) {
                          final date = UtilFunctions.formatDate(DateTime.now());
                          final time = UtilFunctions.formatTime(DateTime.now());
                          Position position = await UtilFunctions.determinePosition();
                          final address = await UtilFunctions.determineAddress(
                            latitude: position.latitude,
                            longitude: position.longitude,
                          );
                          ref
                              .read(photosViewModel.notifier)
                              .updatePhotosList(
                                PhotoModel(
                                  id: const Uuid().v4(),
                                  date: date,
                                  time: time,
                                  localPath: image.path,
                                  location: address,
                                    createdAt: DateTime.now(),
                                ),
                              );
                        }
                      } catch (e, s) {
                        print("An error occured $e at\n$s");
                      }
                    },
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 5, color: AppColors.kPrimary),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ref.read(cameraControllerProvider.notifier).switchCamera();
                    },
                    child: Container(
                      height: 45,
                      width: 45,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.kTextSecondary),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cameraswitch_rounded,
                        color: AppColors.kTextPrimary,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // else if (cameraState.hasValue && uiState is CameraPermissionDenied)
          ],
        ),
      ),
    );
  }
}
