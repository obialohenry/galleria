import 'dart:io';
import 'package:galleria/src/components.dart';
import 'package:galleria/src/config.dart';
import 'package:galleria/src/model.dart';
import 'package:galleria/src/package.dart';
import 'package:galleria/src/screens.dart';
import 'package:galleria/src/view_model.dart';
import 'package:galleria/utils/util_functions.dart';
import 'package:permission_handler/permission_handler.dart';

class TakePhotoScreen extends ConsumerStatefulWidget {
  const TakePhotoScreen({super.key});

  @override
  ConsumerState<TakePhotoScreen> createState() => _TakePhotoScreenState();
}

class _TakePhotoScreenState extends ConsumerState<TakePhotoScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(cameraControllerProvider.notifier).reCheckCameraPermissionStatusandUpdateState();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraControllerProvider);
    final uiState = cameraState.value;
    final photosProvider = ref.watch(photosViewModel);
    return Scaffold(
      backgroundColor: AppColors.kBackgroundPrimary,
      body: SafeArea(
        child: cameraState.isLoading
            ?
              // ---------- LOADING (STATE) ---------- //
              Expanded(
                flex: 3,
                child: Container(
                  color: Colors.transparent,
                  child: Center(child: CircularProgressIndicator(color: AppColors.kPrimary)),
                ),
              )
            : (uiState is CameraReady)
            ?
              // ---------- CAMERA IS READY (STATE) ---------- //
              Column(
                children: [
                  CameraPreview(uiState.controller),
                  Spacer(flex: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        photosProvider.isEmpty
                            ? SizedBox(height: 45, width: 45)
                            : GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PhotoDetailsScreen(index: photosProvider.length - 1),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: FileImage(File(photosProvider.last.localPath)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                        GestureDetector(
                          onTap: () async {
                            try {
                              final File? image = await ref
                                  .read(cameraControllerProvider.notifier)
                                  .takePicture();
                              if (image != null) {
                                final date = UtilFunctions.formatDate(DateTime.now());
                                final time = UtilFunctions.formatTime(DateTime.now());
                                final address = await UtilFunctions.determineAddress();
                                ref
                                    .read(photosViewModel.notifier)
                                    .updatePhotosList(
                                      PhotoModel(
                                        id: const Uuid().v4(),
                                        date: date,
                                        time: time,
                                        localPath: image.path,
                                        location: address,
                                        createdAt: DateTime.now(),
                                      ),
                                    );
                              }
                            } catch (e, s) {
                              print("An error occured $e at\n$s");
                            }
                          },
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(width: 5, color: AppColors.kPrimary),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            ref.read(cameraControllerProvider.notifier).switchCamera();
                          },
                          child: Container(
                            height: 45,
                            width: 45,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.kTextSecondary),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.cameraswitch_rounded,
                              color: AppColors.kTextPrimary,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : (uiState is CameraPermissionDenied)
            ?
              // ---------- CAMERA PERMISSIONS ARE DENIED (STATE) ---------- //
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.no_photography, color: AppColors.kInactiveColor, size: 100),
                    SizedBox(height: 15),
                    AppText(
                      text: AppStrings.cameraPermissionRequiredToTakePhotos,
                      color: AppColors.kTextSecondary,
                    ),
                    SizedBox(height: 50),
                    Visibility(
                      visible: uiState.isPermanentlyDenied,
                      replacement: AppButton(
                        text: AppStrings.enableCameraPermission,
                        onTap: () {
                          ref
                              .read(cameraControllerProvider.notifier)
                              .requestCameraPermissionAndUpdateState();
                        },
                      ),
                      child: AppButton(
                        text: AppStrings.openAppSettings,
                        onTap: () {
                          openAppSettings();
                        },
                      ),
                    ),
                  ],
                ),
              )
            : (uiState is CameraFailure)
            ?
              // ---------- FAILURE (STATE) ---------- //
              Expanded(
                flex: 2,
                child: Container(
                  color: AppColors.kPrimary,
                  child: Center(child: AppText(text: uiState.message)),
                ),
              )
            : SizedBox.shrink(),
      ),
    );
  }
}
