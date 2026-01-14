import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galleria/config/app_colors.dart';
import 'package:galleria/view/components/app_text.dart';
import 'package:galleria/view/screens/photos/photo_details_screen.dart';
import 'package:galleria/view_model/cameras_view_model.dart';

// ignore: must_be_immutable
class TakePhotoScreen extends ConsumerStatefulWidget {
  const TakePhotoScreen({super.key});

  @override
  ConsumerState<TakePhotoScreen> createState() => _TakePhotoScreenState();
}

class _TakePhotoScreenState extends ConsumerState<TakePhotoScreen> {
  File? image;

  @override
  Widget build(BuildContext context) {
    final camerasProvider = ref.watch(cameraControllerProvider);
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
                  image == null
                      ? SizedBox(height: 45, width: 45)
                      : GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PhotoDetailsScreen()),
                      );
                    },
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                                image: FileImage(File(image!.path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      try {
                        image = await ref.read(cameraControllerProvider.notifier).takePicture();
                        print("PICTURE: ${image?.path}");
                        setState(() {});
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
