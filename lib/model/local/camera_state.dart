import 'package:camera/camera.dart';

class CameraState {
  final CameraController controller;
  final int cameraIndex;
  bool isSnapping;

  CameraState({required this.controller, required this.cameraIndex, this.isSnapping = false});

  CameraState withChanges({CameraController? controller, int? cameraIndex, bool? isSnapping}) {
    return CameraState(
      controller: controller ?? this.controller,
      cameraIndex: cameraIndex ?? this.cameraIndex,
      isSnapping: isSnapping ?? this.isSnapping,
    );
  }
}
