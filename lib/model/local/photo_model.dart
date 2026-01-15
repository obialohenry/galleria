
class Photo {
  final String? date;
  final String? time;
  final String? localPath;
  final String? location;
  bool syncStatus;
  Photo({this.date,this.time,this.localPath,this.location,this.syncStatus = false});
}
