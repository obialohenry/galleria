import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galleria/config/app_colors.dart';
import 'package:galleria/config/app_strings.dart';
import 'package:galleria/model/local/photo_model.dart';
import 'package:galleria/utils/util_functions.dart';
import 'package:galleria/view/components/app_text.dart';
import 'package:galleria/view/screens/photos/photo_details_screen.dart';
import 'package:galleria/view_model/cameras_view_model.dart';
import 'package:galleria/view_model/photos_view_model.dart';
import 'package:geolocator/geolocator.dart';

// ignore: must_be_immutable
class TakePhotoScreen extends ConsumerWidget {
  const TakePhotoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camerasProvider = ref.watch(cameraControllerProvider);
    final photoProvider = ref.watch(photoViewModel);
    return Scaffold(
      backgroundColor: AppColors.kBackgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            camerasProvider.when(
              loading: () => Expanded(
                flex: 3,
                child: Container(
                  color: Colors.transparent,
                  child: Center(child: CircularProgressIndicator(color: AppColors.kPrimary)),
                ),
              ),

              error: (error, stackTrace) => Expanded(
                flex: 2,
                child: Container(
                  color: AppColors.kPrimary,
                  child: Center(child: AppText(text: error.toString())),
                ),
              ),
              data: (cameraState) {
                return CameraPreview(cameraState.controller);
              },
            ),
            Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  photoProvider.localPath == null
                      ? SizedBox(height: 45, width: 45)
                      : GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhotoDetailsScreen(
                                  address: photoProvider.location ?? AppStrings.unknownData,
                                  date: photoProvider.date ?? AppStrings.unknownData,
                                  image: photoProvider.localPath!,
                                  syncStatus: photoProvider.syncStatus,
                                  time: photoProvider.time ?? AppStrings.unknownData,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: FileImage(File(photoProvider.localPath!)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                  GestureDetector(
                    onTap: () async {
                      try {
                        final date = UtilFunctions.formatDate(DateTime.now());
                        final time = UtilFunctions.formatTime(DateTime.now());
                        Position position = await UtilFunctions.determinePosition();
                        final address = await UtilFunctions.determineAddress(
                          latitude: position.latitude,
                          longitude: position.longitude,
                        );
                        final File image = await ref
                            .read(cameraControllerProvider.notifier)
                            .takePicture();
                        print(
                          "date:$date\ntime:$time\nlat:${position.latitude}\nlong:${position.longitude}\naddress:$address\nimage:${image.path}",
                        );
                        ref
                            .read(photoViewModel.notifier)
                            .changedPhoto(
                              localPath: image.path,
                              date: date,
                              time: time,
                              location: address,
                            );
                        ref
                            .read(photosViewModel.notifier)
                            .updatePhotosList(
                              PhotoModel(
                                date: date,
                                time: time,
                                localPath: image.path,
                                location: address,
                              ),
                            );
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
          ],
        ),
      ),
    );
  }
}
