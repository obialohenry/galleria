import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galleria/local_storage/photo_local_db.dart';
import 'package:galleria/model/local/photo_model.dart';

final photosViewModel = AsyncNotifierProvider<PhotosViewModel, List<PhotoModel>>(
  PhotosViewModel.new,
);

class PhotosViewModel extends AsyncNotifier<List<PhotoModel>> {
  @override
  FutureOr<List<PhotoModel>> build() {
    return PhotosLocalDb().getAllPhotos();
  }

  void updatePhotosList(PhotoModel photo) async {
    final currentList = state.value ?? [];
    final List<PhotoModel> newList = [...currentList, photo];
    state = AsyncData(newList);
    await PhotosLocalDb().savePhoto(photo);
  }
}
