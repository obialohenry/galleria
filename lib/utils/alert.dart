import 'package:flutter/material.dart';
import 'package:galleria/src/config.dart';
import 'package:galleria/view/components/app_text.dart';

void comingSoonDialog(BuildContext context) {
  showDialog(
    context: context,
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
         text: AppStrings.okay,color: AppColors.kContentAlert,
        ),
          ),
        ],
      );
    },
  );
}
