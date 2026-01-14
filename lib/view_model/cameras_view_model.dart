import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galleria/model/local/camera_state.dart';

final availableCamerasProvider =
    AsyncNotifierProvider<AvailableCamerasProvider, List<CameraDescription>>(
      AvailableCamerasProvider.new,
    );

class AvailableCamerasProvider extends AsyncNotifier<List<CameraDescription>> {
  @override
  FutureOr<List<CameraDescription>> build() async {
    return await availableCameras();
  }
}

final cameraControllerProvider = AsyncNotifierProvider<CameraControllerProvider, CameraState>(
  CameraControllerProvider.new,
);

class CameraControllerProvider extends AsyncNotifier<CameraState> {
  CameraController? _controller;

  @override
  FutureOr<CameraState> build() async {
    final cameras = await ref.watch(availableCamerasProvider.future);
    ref.onDispose(() {
      _controller?.dispose();
    });

    return _initializeCamera(cameras: cameras, cameraIndex: 0);
  }

  Future<CameraState> _initializeCamera({
    required List<CameraDescription> cameras,
    required int cameraIndex,
  }) async {
    await _controller?.dispose();

    _controller = CameraController(cameras[cameraIndex], ResolutionPreset.max);
    await _controller!.initialize();
    return CameraState(
      controller: _controller!,
      cameraIndex: cameraIndex,
    );
  }

  Future<void> switchCamera() async {
    final cameras = await ref.read(availableCamerasProvider.future);
    final currentIndex = state.value!.cameraIndex;

    state = const AsyncLoading();

    state = AsyncValue.data(
      await _initializeCamera(cameras: cameras, cameraIndex: (currentIndex + 1) % cameras.length),
    );
  }

  Future<XFile> takePicture() async {
    final cameraState = state.value!;
    await cameraState.controller.initialize();
    return await cameraState.controller.takePicture();
  }
}
