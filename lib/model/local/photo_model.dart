import 'package:hive/hive.dart';

part 'photo_model.g.dart';

@HiveType(typeId: 0)
class PhotoModel extends HiveObject {
  @HiveField(0)
  String? date;

  @HiveField(1)
  String? time;

  @HiveField(2)
  String? localPath;

  @HiveField(3)
  String? location;

  @HiveField(4)
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
