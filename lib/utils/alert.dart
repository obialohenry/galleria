import 'package:flutter/material.dart';
import 'package:galleria/src/config.dart';
import 'package:galleria/view/components/app_text.dart';
import 'package:galleria/view/components/sync_process_dialog_widget.dart';

void comingSoonDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.kSurfaceAlert,
        title: AppText(
          text: AppStrings.comingSoon,
          color: AppColors.kContentAlert,
          fontWeight: FontWeight.w600,
        ),
        content: AppText(
          text: AppStrings.thisFeatureIsUnderDevelopment,
          color: AppColors.kContentAlert,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText(text: AppStrings.okay, color: AppColors.kSuccess),
          ),
        ],
      );
    },
  );
}

void syncProcessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => SyncProcessDialogWidget(),
  );
}
