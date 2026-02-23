import 'package:camera/camera.dart';

abstract class CameraUiState {}

class CameraReady extends CameraUiState {
  final CameraController controller;
  final int cameraIndex;

  CameraReady({required this.controller, required this.cameraIndex});
}

class CameraPermissionDenied extends CameraUiState {}

class CameraFailure extends CameraUiState {
  final String message;

  CameraFailure(this.message);
}
