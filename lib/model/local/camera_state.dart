import 'package:camera/camera.dart';

class CameraState {
  final CameraController controller;
  final int cameraIndex;

  CameraState({required this.controller, required this.cameraIndex});
}
