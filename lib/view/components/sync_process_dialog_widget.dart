import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galleria/model/local/photo_sync_state.dart';
import 'package:galleria/src/config.dart';
import 'package:galleria/src/utils.dart';
import 'package:galleria/src/view_model.dart';
import 'package:galleria/view/components/app_text.dart';

class SyncProcessDialogWidget extends ConsumerWidget {
  const SyncProcessDialogWidget({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
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
                          text: _syncStateTitle(syncState.status),
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
  }

  /// Returns the feedback dialog title for each sync process state.
  ///
  /// Sync states includes; idle, compressing, uploading, success, error.
  String _syncStateTitle(PhotoSyncStatus syncState) {
    return switch (syncState) {
      PhotoSyncStatus.idle => "",
      PhotoSyncStatus.compressing => AppStrings.compressingPhoto,
      PhotoSyncStatus.uploading => AppStrings.uploadingToCloud,
      PhotoSyncStatus.success => AppStrings.photoSyncedSuccessfully,
      PhotoSyncStatus.error => AppStrings.syncFailed,
    };
  }

  /// Returns the feedback dialog content for each sync process state.
  ///
  /// Sync states includes; idle, compressing, uploading, success, error.
  Widget _syncProcessContent(PhotoSyncState syncState, BuildContext context) {
    return switch (syncState.status) {
      PhotoSyncStatus.idle => AppText(
        text: AppStrings.checkingInternetConnection,
        color: AppColors.kContentAlert,
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
      PhotoSyncStatus.compressing => Column(
        children: [
          SizedBox(height: 50),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.kBackgroundPrimary),
          ),
        ],
      ),
      PhotoSyncStatus.uploading => Column(
        children: [
          SizedBox(height: 50),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.kBackgroundPrimary),
          ),
        ],
      ),
      PhotoSyncStatus.success => Column(
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
      PhotoSyncStatus.error => Column(
        children: [
          Image(image: AssetImage(AppImages.errorIcon)),
          SizedBox(height: 10),
          AppText(
            text: syncState.errorMessage??'',
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
}