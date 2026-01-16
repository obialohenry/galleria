import 'package:hive/hive.dart';

part 'photo_model.g.dart';

@HiveType(typeId: 0)
class PhotoModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? date;

  @HiveField(2)
  String? time;

  @HiveField(3)
  String? localPath;

  @HiveField(4)
  String? location;

  @HiveField(5)
  bool isSynced;

  @HiveField(6)
  String? cloudId;

  PhotoModel({
    required this.id,
    this.date,
    this.time,
    this.localPath,
    this.location,
    this.isSynced = false,
    this.cloudId,
  });
}
