import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:galleria/model/local/camera_state.dart';
import 'package:galleria/src/package.dart';
import 'package:galleria/utils/util_functions.dart';

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
  AudioPlayer? _player;
  @override
  FutureOr<CameraState> build() async {
    final cameras = await ref.watch(availableCamerasProvider.future);
    ref.onDispose(() {
      _controller?.dispose();
      _player?.dispose();
    });

    return await _initializeCamera(cameras: cameras, cameraIndex: 0);
  }

  ///Returns a new instance of camera state.
  ///
  ///parameters:
  ///-cameras: The list of available cameras from the Camera plugin
  ///-cameraIndex: The index number used to get a camera item from the list.
  ///
  ///Disposes of previous camera controller is any.
  ///Creates a new camera controller, a camera item and it's resolution.
  ///Initializes the controller and returns a new camera state instance using the controller and camera index.
  Future<CameraState> _initializeCamera({
    required List<CameraDescription> cameras,
    required int cameraIndex,
  }) async {
    await _controller?.dispose();

    _controller = CameraController(cameras[cameraIndex], ResolutionPreset.max);
    await _controller!.initialize();
    return CameraState(controller: _controller!, cameraIndex: cameraIndex);
  }

  ///Switch between front and back cameras.
  Future<void> switchCamera() async {
    state = const AsyncLoading();

    final cameras = await ref.read(availableCamerasProvider.future);
    final currentIndex = state.value!.cameraIndex;

    state = AsyncValue.data(
      await _initializeCamera(cameras: cameras, cameraIndex: (currentIndex + 1) % cameras.length),
    );
  }

  ///Play camera capture sound.
  Future<void> sound() async {
    _player = AudioPlayer();
    try {
      await _player?.play(AssetSource("audio/camera_sound.mp3"));
    } catch (e, s) {
      debugPrint("Sound Failed: $e \n at $s");
    }
  }

  ///Take a photo and save it to the Galleria album on the device.
  Future<File?> takePicture() async {
    if (!state.hasValue || _controller == null) {
      return null;
    }

    final cameraState = state.value!;
    if (!cameraState.controller.value.isTakingPicture) {
      final XFile xFile = await cameraState.controller.takePicture();
      final imageFile = File(xFile.path);
      final success = await UtilFunctions.saveImageToDeviceGallery(file: imageFile);
      if (!success) {
        return null;
      }
      await sound();
      return imageFile;
    }
    return null;
  }
}
