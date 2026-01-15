import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galleria/model/local/photo_model.dart';

final photoViewModel = NotifierProvider<PhotoViewModel, PhotoModel>(PhotoViewModel.new);

class PhotoViewModel extends Notifier<PhotoModel> {
  @override
  PhotoModel build() {
    return PhotoModel();
  }

  void changedPhoto({
    String? date,
    String? time,
    String? localPath,
    String? location,
    bool? syncStatus,
  }) {
    state = state.withChanges(
      date: date,
      time: time,
      localPath: localPath,
      location: location,
      syncStatus: syncStatus,
    );
  }
}
