import 'package:galleria/src/utils.dart';

class PhotoSyncState {
  final PhotoSyncStatus status;
  final String? errorMessage;

  PhotoSyncState({this.status = PhotoSyncStatus.idle, this.errorMessage});

  PhotoSyncState withChanges({required PhotoSyncStatus status, String? errorMessage}) {
    return PhotoSyncState(
      status: status,
      errorMessage: errorMessage??this.errorMessage,
    );
  }
}
