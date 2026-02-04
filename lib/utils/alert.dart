import 'package:flutter/material.dart';
import 'package:galleria/src/config.dart';
import 'package:galleria/view/components/app_text.dart';

void comingSoonDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.kSurfaceAlert,
        title: AppText(text: AppStrings.comingSoon,color: AppColors.kContentAlert,fontWeight: FontWeight.w600,),
        content:  AppText(
         text: AppStrings.thisFeatureIsUnderDevelopment,color: AppColors.kContentAlert,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText(
         text: AppStrings.okay, color: AppColors.kSuccess,
        ),
          ),
        ],
      );
    },
  );
}

void syncProcessDialog(BuildContext context, {required String title, required Widget content}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.kSurfaceAlert,
        constraints: BoxConstraints(maxHeight: 200, maxWidth: 400),
        title: AppText(text: title, color: AppColors.kContentAlert, fontWeight: FontWeight.w600),
        content: content,
      );
    },
  );
}
