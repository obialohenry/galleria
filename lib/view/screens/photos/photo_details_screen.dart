import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galleria/src/config.dart';
import 'package:galleria/src/view_model.dart';
import 'package:galleria/utils/util_functions.dart';
import 'package:galleria/view/components/app_text.dart';

class PhotoDetailsScreen extends ConsumerWidget {
  const PhotoDetailsScreen({
    super.key,
    required this.image,
    required this.address,
    required this.date,
    required this.time,
    required this.isSynced,
    required this.id,
    required this.cloudReferenceUrl,
  });
  final String id;
  final String image;
  final String date;
  final String time;
  final String address;
  final bool isSynced;
  final String? cloudReferenceUrl;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(photosViewModel);
    return Scaffold(
      backgroundColor: AppColors.kBackgroundPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 15, top: 15, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back, color: AppColors.kTextPrimary, size: 30),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(text: date, fontWeight: FontWeight.w700),
                          AppText(text: time, color: AppColors.kTextSecondary, fontSize: 14),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      !isSynced
                          ? ref
                                .watch(cloudSyncViewModel.notifier)
                                .syncPhoto(context, file: File(image), photoId: id)
                          : debugPrint("THIS PHOTO IS ALREADY SYNCED");
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: !isSynced
                            ? ref.read(cloudSyncViewModel.notifier).syncButtonColor()
                            : AppColors.kSuccess,
                      ),
                      child: AppText(
                        text: !isSynced
                            ? ref.read(cloudSyncViewModel.notifier).syncButtonActionText()
                            : AppStrings.synced,
                        color: AppColors.kPrimaryPressed,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: FileImage(File(image)), fit: BoxFit.cover),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  AppText(text: AppStrings.location, fontWeight: FontWeight.w700),
                  SizedBox(height: 5),
                  AppText(text: address, color: AppColors.kTextSecondary),
                  Visibility(
                    visible: cloudReferenceUrl != null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Row(
                          children: [
                            AppText(text: AppStrings.cloudUrl, fontWeight: FontWeight.w700),
                            SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                UtilFunctions.copyToClipBoard(
                                  context,
                                  value: cloudReferenceUrl ?? "",
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.kSuccess),
                                ),
                                child: AppText(
                                  text: AppStrings.copy,
                                  color: AppColors.kSurfaceAlert,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
