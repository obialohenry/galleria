import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galleria/src/config.dart';
import 'package:galleria/src/utils.dart';
import 'package:galleria/src/view_model.dart';
import 'package:galleria/view/components/app_text.dart';

class PhotoDetailsScreen extends ConsumerWidget {
  const PhotoDetailsScreen({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosProvider = ref.watch(photosViewModel);
    final syncState = ref.watch(cloudSyncViewModel);
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
                          AppText(text: photosProvider[index].date, fontWeight: FontWeight.w700),
                          AppText(
                            text: photosProvider[index].time,
                            color: AppColors.kTextSecondary,
                            fontSize: 14,
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      if (!photosProvider[index].isSynced) {
                        syncProcessDialog(context);
                        ref
                            .read(cloudSyncViewModel.notifier)
                            .syncPhoto(
                              file: File(photosProvider[index].localPath),
                              photoId: photosProvider[index].id,
                            );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: !photosProvider[index].isSynced
                            ? _syncButtonColor(syncState.status)
                            : AppColors.kSuccess,
                      ),
                      child: AppText(
                        text: !photosProvider[index].isSynced
                            ? _syncButtonActionText(syncState.status)
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
                  image: DecorationImage(
                    image: FileImage(File(photosProvider[index].localPath)),
                    fit: BoxFit.cover,
                  ),
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
                  AppText(text: photosProvider[index].location, color: AppColors.kTextSecondary),
                  Visibility(
                    visible: photosProvider[index].cloudId != null,
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
                                  value: photosProvider[index].cloudId ?? "",
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

  /// Changes the sync photo action buttons colour based on the sync process state.
  ///
  /// Sync states includes; idle, compressing, uploading, success, error.
  Color _syncButtonColor(PhotoSyncStatus state) {
    return switch (state) {
      PhotoSyncStatus.idle || PhotoSyncStatus.error => AppColors.kPrimary,
      PhotoSyncStatus.compressing || PhotoSyncStatus.uploading => AppColors.kPending,
      PhotoSyncStatus.success => AppColors.kSuccess,
    };
  }

  /// Changes the sync photo action buttons text based on the sync process state.
  ///
  /// Sync states includes; idle, compressing, uploading, success, error.
  String _syncButtonActionText(PhotoSyncStatus state) {
    return switch (state) {
      PhotoSyncStatus.idle || PhotoSyncStatus.error => AppStrings.syncPhoto,
      PhotoSyncStatus.compressing || PhotoSyncStatus.uploading => AppStrings.syncing,
      PhotoSyncStatus.success => AppStrings.synced,
    };
  }
}
