class PhotoModel {
  final String? date;
  final String? time;
  final String? localPath;
  final String? location;
  bool syncStatus;

  PhotoModel({this.date, this.time, this.localPath, this.location, this.syncStatus = false});

  PhotoModel withChanges({
    String? date,
    String? time,
    String? localPath,
    String? location,
    bool? syncStatus,
  }) {
    return PhotoModel(
      date: date ?? this.date,
      time: time ?? this.time,
      localPath: localPath ?? this.localPath,
      location: location ?? this.location,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
