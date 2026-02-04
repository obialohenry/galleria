import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galleria/local_storage/photo_local_db.dart';
import 'package:galleria/model/local/photo_model.dart';

final photosViewModel = NotifierProvider<PhotosViewModel, List<PhotoModel>>(PhotosViewModel.new);

class PhotosViewModel extends Notifier<List<PhotoModel>> {
  @override
  List<PhotoModel> build() {
    return PhotosLocalDb().getAllPhotos();
  }

  ///Update  list of photo's(a PhotoModel object) and save to Hive's database.
  ///
  ///Updates list with previous PhotoModel object if any, and new onw.
  ///Saves newly updated list to the data base.
  void updatePhotosList(PhotoModel photo) async {
    final success = await PhotosLocalDb().savePhoto(photo);
    if (success) {
      final currentList = state;
      final List<PhotoModel> newList = [...currentList, photo];
      state = newList;
    }
  }

  ///Update a photo item's metadata, and return the Updated photo item.
  ///
  ///parameters:
  ///- photoId: A photo item's unique ID.
  ///- cloudReferenceId: The dowloadable URL of a photo item, gotten after a successful upload to the cloud.
  ///
  ///This get's the index of a photo item in the list of photos state.
  ///It then uses the index to get the photo item from the list, updating the [isSynced] and [cloudId] status of the item, updates the state list, and returning the updated photo item.
  ///The [cloudId] status is updated with the cloudReferenceId argument.
  PhotoModel updateAPhoto({required String photoId, required String cloudReferenceId}) {
    final index = state.indexWhere((photo) => photo.id == photoId);

    final updatedPhoto = state[index].withChanges(isSynced: true, cloudId: cloudReferenceId);

    final newList = [...state];
    newList[index] = updatedPhoto;

    state = newList;

    return updatedPhoto;
  }
}
