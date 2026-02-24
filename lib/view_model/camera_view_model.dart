import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:galleria/model/local/camera_ui_state.dart';
import 'package:galleria/src/package.dart';
import 'package:galleria/utils/util_functions.dart';
import 'package:permission_handler/permission_handler.dart';

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

final cameraControllerProvider = AsyncNotifierProvider<CameraControllerProvider, CameraUiState>(
  CameraControllerProvider.new,
);

class CameraControllerProvider extends AsyncNotifier<CameraUiState> {
  CameraController? _controller;
  AudioPlayer? _player;
  @override
  FutureOr<CameraUiState> build() async {
    final cameras = await ref.watch(availableCamerasProvider.future);
    ref.onDispose(() {
      _controller?.dispose();
      _player?.dispose();
    });
    if (cameras.isEmpty) {
      return CameraFailure("No cameras available");
    }

    return await _initializeCamera(cameras: cameras, cameraIndex: 0);
  }

  ///Returns a type of camera ui state (CameraUiState).
  ///
  ///parameters:
  ///-cameras: The list of available cameras from the Camera plugin
  ///-cameraIndex: The index number used to get a camera item from the list.
  ///
  ///Disposes of previous camera controller is any.
  ///Creates a new camera controller, a camera item and it's resolution.
  ///Initializes the controller and returns a `CameraReady` type using the controller and camera index.
  ///If a CameraException occurs, it returns a `CameraPermissionDenied` type if the exception code is any of the following:
  ///- CameraAccessDenied
  ///- CameraAccessDeniedWithoutPrompt
  ///- CameraAccessRestricted.
  ///It then returns a `CameraFailure` type on any other CameraException, or Exceptions.
  Future<CameraUiState> _initializeCamera({
    required List<CameraDescription> cameras,
    required int cameraIndex,
  }) async {
    try {
      await _controller?.dispose();

      _controller = CameraController(cameras[cameraIndex], ResolutionPreset.max);
      await _controller!.initialize();
      return CameraReady(controller: _controller!, cameraIndex: cameraIndex);
    } on CameraException catch (e) {
      if (e.code == 'CameraAccessDenied' || e.code == 'CameraAccessRestricted') {
        return CameraPermissionDenied();
      }

      if (e.code == 'CameraAccessDeniedWithoutPrompt') {
        return CameraPermissionDenied(isPermanentlyDenied: true);
      }

      return CameraFailure(e.description ?? e.code);
    } catch (e) {
      return CameraFailure(e.toString());
    }
  }

  ///Switch between front and back cameras and initialize respective camera, when the state has value, and is of CameraReady type.
  Future<void> switchCamera() async {
    final currentState = state.value;

    if (currentState == null) return;

    if (currentState is! CameraReady) return;

    final currentIndex = currentState.cameraIndex;

    state = const AsyncLoading();

    final cameras = await ref.read(availableCamerasProvider.future);

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

  //TODO: Re-structure this takePicture method below to handle edgecases properly.
  ///Take a photo and save it to the Galleria album on the device, when the state has value, and is of CameraReady type.
  Future<File?> takePicture() async {
    final currentState = state.value;

    if (currentState == null || _controller == null) {
      return null;
    }

    if (currentState is! CameraReady) {
      return null;
    }
    final cameraController = currentState.controller;
    if (!cameraController.value.isTakingPicture) {
      final XFile xFile = await cameraController.takePicture();
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

  Future<void> requestCameraPermissionAndChangeUIState() async {
    final permissionStatus = await UtilFunctions.requestCameraPermssion();

    if (permissionStatus.isGranted) {
      final cameras = await ref.read(availableCamerasProvider.future);
      state = AsyncValue.data(await _initializeCamera(cameras: cameras, cameraIndex: 0));
    } else if (permissionStatus.isDenied) {
      state = AsyncValue.data(CameraPermissionDenied());
    } else if (permissionStatus.isPermanentlyDenied) {
      state = AsyncValue.data(CameraPermissionDenied(isPermanentlyDenied: true));
    }
  }
}
