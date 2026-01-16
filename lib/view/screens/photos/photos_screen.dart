import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galleria/src/config.dart';
import 'package:galleria/src/model.dart';
import 'package:galleria/src/screens.dart';
import 'package:galleria/src/view_model.dart';
import 'package:galleria/view/components/app_text.dart';

class PhotosScreen extends ConsumerWidget {
  const PhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosProvider = ref.watch(photosViewModel);
    return Scaffold(
      backgroundColor: AppColors.kBackgroundPrimary,
      body: SafeArea(
        child: photosProvider.when(
          data: (photos) {
            return photos.isNotEmpty
                ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.5,
                    ),
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      PhotoModel aGridPhoto = photos[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhotoDetailsScreen(
                                address: aGridPhoto.location ?? AppStrings.unknownData,
                                date: aGridPhoto.date ?? AppStrings.unknownData,
                                image: aGridPhoto.localPath!,
                                syncStatus: aGridPhoto.isSynced,
                                time: aGridPhoto.time ?? AppStrings.unknownData,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 250,
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(File(aGridPhoto.localPath!)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: AppText(
                        text: AppStrings.noPhotosYet,
                        color: AppColors.kTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
          },
          error: (error, stackTrace) => Expanded(
            flex: 2,
            child: Container(
              color: AppColors.kPrimary,
              child: Center(child: AppText(text: error.toString())),
            ),
          ),
          loading: () => Expanded(
            flex: 3,
            child: Container(
              color: Colors.transparent,
              child: Center(child: CircularProgressIndicator(color: AppColors.kPrimary)),
            ),
          ),
        ),
      ),
    );
  }
}
