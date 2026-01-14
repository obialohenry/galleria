import 'package:flutter/material.dart';
import 'package:galleria/config/app_colors.dart';
import 'package:galleria/config/app_strings.dart';
import 'package:galleria/view/components/app_text.dart';

class PhotoDetailsScreen extends StatefulWidget {
  const PhotoDetailsScreen({super.key, this.image});
  final String? image;
  @override
  State<PhotoDetailsScreen> createState() => _PhotoDetailsScreenState();
}

class _PhotoDetailsScreenState extends State<PhotoDetailsScreen> {
  @override
  Widget build(BuildContext context) {
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
                          AppText(text: "07/01/2026", fontWeight: FontWeight.w700),
                          AppText(text: "7:44 AM", color: AppColors.kTextSecondary, fontSize: 14),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.kBackgroundSecondary,
                      ),
                      child: AppText(
                        text: AppStrings.syncPhoto,
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
                    image: AssetImage(widget.image ?? "assets/images/daenerys.jpeg"),
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
                  AppText(text: "123 Main Street...", color: AppColors.kTextSecondary),
                  SizedBox(height: 10),
                  AppText(text: AppStrings.localPath, fontWeight: FontWeight.w700),
                  SizedBox(height: 5),
                  AppText(text: "/storage/emulated/...", color: AppColors.kTextSecondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
