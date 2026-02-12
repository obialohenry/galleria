import 'package:hive/hive.dart';

part 'photo_model.g.dart';

@HiveType(typeId: 0)
class PhotoModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String date;

  @HiveField(2)
  String time;

  @HiveField(3)
  String localPath;

  @HiveField(4)
  String location;

  @HiveField(5)
  bool isSynced;

  @HiveField(6)
  String? cloudId;

  @HiveField(7)
  DateTime createdAt;

  PhotoModel({
    required this.id,
    required this.date,
    required this.time,
    required this.localPath,
    required this.location,
    required this.createdAt,
    this.isSynced = false,
    this.cloudId,
  });

  PhotoModel withChanges({bool? isSynced, String? cloudId}) {
    return PhotoModel(
      id: id,
      date: date,
      time: time,
      localPath: localPath,
      location: location,
      createdAt: createdAt,
      isSynced: isSynced ?? this.isSynced,
      cloudId: cloudId ?? this.cloudId,
    );
  }
}
