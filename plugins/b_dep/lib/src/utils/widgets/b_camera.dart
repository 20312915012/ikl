import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:b_dep/b_dep.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import "package:universal_html/html.dart" as html;
import 'package:universal_io/io.dart' as io;
import 'package:video_player/video_player.dart';

import 'b_camera_utils/dart_ui.dart' as ui;

List<CameraDescription> initCameras = <CameraDescription>[];

class BCameraView extends BStatefulWidget {
  BCameraView({
    Key key,
    String id,
    this.width,
    this.height,
    this.type,
    this.allowZoomInZoomOut,
    this.showRecentFileSelector,
    this.onWebviewDefaultPropUpdate,
    this.onWebviewExtraPropUpdate,
    this.onFileSubmit,
    this.background,
    this.textColor,
    this.iconsColor,
    this.selectedTextColor,
    this.videoRecordColor,
  }) : super(
    key: key,
    id: id,
    width: width,
    height: height,
  );

  bool showRecentFileSelector;
  bool allowZoomInZoomOut;
  String type;

  double width;
  double height;
  final Color background;
  final Color iconsColor;
  final Color textColor;
  final Color selectedTextColor;
  final Color videoRecordColor;
  final Function onWebviewDefaultPropUpdate;
  final Function onWebviewExtraPropUpdate;
  final void Function(String, Uint8List) onFileSubmit;

  @override
  BState<BStatefulWidget> createState() => _BCameraViewState();
}

class _BCameraViewState extends BState<BCameraView> with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController controller;
  XFile imageFile;
  XFile videoFile;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  bool enableAudio = true;
  AnimationController _flashModeControlRowAnimationController;
  AnimationController _exposureModeControlRowAnimationController;
  AnimationController _focusModeControlRowAnimationController;
  final double _minAvailableZoom = 1.0;
  final double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  CameraLensDirection cameraLensDirection = CameraLensDirection.front;
  bool isPicCaptured = false;
  bool isVideoCaptured = false;
  bool isVideoType = false;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;
  bool isLoading = true;

  // #docregion AppLifecycle

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  // #enddocregion AppLifecycle

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final CameraController oldController = controller;
    if (oldController != null) {
      // `controller` needs to be set to null before getting disposed,
      // to avoid a race condition when we use the controller that is being
      // disposed. This happens when camera permission dialog shows up,
      // which triggers `didChangeAppLifecycleState`, which disposes and
      // re-creates the controller.
      controller = null;
      await oldController.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar('Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
        // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
          showInSnackBar('Camera access is restricted.');
          break;
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
          break;
        case 'AudioAccessDeniedWithoutPrompt':
        // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
          break;
        case 'AudioAccessRestricted':
        // iOS only
          showInSnackBar('Audio access is restricted.');
          break;
        case 'cameraPermission':
        // Android & web only
          showInSnackBar('Unknown permission error.');
          break;
        default:
          _showCameraException(e);
          break;
      }
    }
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void _logError(String code, String message) {
    if (message != null) {
      print('Error: $code\nError Message: $message');
    } else {
      print('Error: $code');
    }
  }

  @override
  void initState() {
    super.initState();
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    _ambiguate(WidgetsBinding.instance)?.addObserver(this);

    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    if (initCameras.isEmpty) {
      availableCameras().then((_) {
        initCameras = _;
        setInitCamera(CameraLensDirection.front);
      });
    } else {
      setInitCamera(CameraLensDirection.front);
    }
    // onTakePictureButtonPressed();
  }

  void setInitCamera(CameraLensDirection lensDirection) {
    if (initCameras.isNotEmpty) {
      if (initCameras.any((element) => element.lensDirection == lensDirection)) {
        onNewCameraSelected(initCameras.firstWhere((element) => element.lensDirection == lensDirection));
      } else {
        onNewCameraSelected(initCameras[1]).then((value) {
          cameraLensDirection = initCameras[1].lensDirection;
          // onTakePictureButtonPressed();
        });
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    super.dispose();
  }

  bool isCalled = true;

  @override
  Widget build(BuildContext context) {
    scrUtilConversion();
    PropertyUtils().updateProperties(widget);
    bool showTabBar = false;
    bool isHide = false;
    switch (widget.type) {
      case 'Photos & Videos':
        showTabBar = true;
        break;
      case 'onlyPhotos':
        isVideoType = false;
        break;
      case 'onlyVideos':
        isVideoType = true;
        break;
      case 'none':
        isHide = true;
        break;
    }
    return Container(
      width: widget.width,
      height: widget.height,
      color: widget.background,
      child: isLoading
          ? const CupertinoActivityIndicator(
        radius: 18,
      )
          : Stack(
        children: <Widget>[
          SizedBox(
              width: widget.width,
              height: isHide
                  ? widget.height
                  : (widget.height -
                  ((isPicCaptured || isVideoCaptured || !isHide) ? 140 : 0) -
                  (showTabBar ? 18.0 : 0)),
              child: isPicCaptured
                        ? Center(
                            child: (kIsWeb ? Image.network(imageFile.path) : Image.file(File(imageFile.path))),
                          )
                        : (isVideoCaptured ? _thumbnailWidget() : _cameraPreviewWidget())),
                if (!isHide)
                  Container(
                      alignment: Alignment.bottomCenter,
                      margin: const EdgeInsets.only(bottom: 8.0, left: 12, right: 12),
                      // width: widget.width - 24,
                      child: (isPicCaptured || isVideoCaptured)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  width: 48,
                                ),
                                Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(32),
                                      border: Border.all(width: 3.0, color: widget.iconsColor)),
                                  // padding: const EdgeInsets.all(6.0),
                                  child: IconButton(
                                    splashRadius: 12,
                                    padding: const EdgeInsets.all(0.0),
                                    color: widget.iconsColor,
                                    iconSize: 20,
                                    icon: Icon(
                                      Icons.done_rounded,
                                      color: widget.iconsColor,
                                    ),
                                    onPressed: () async {
                                      Uint8List bytes = await imageFile.readAsBytes();
                                      String filePath;
                                      if (kIsWeb) {
                                        try {
                                          filePath = io.File.fromRawPath(bytes).path;
                                        } catch (ex, st) {
                                          // TODO:- see
                                        }
                                      } else {
                                        filePath = imageFile.path;
                                      }
                                      if (widget.onFileSubmit != null) {
                                        widget.onFileSubmit(filePath, bytes);
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  splashRadius: 12,
                                  padding: const EdgeInsets.all(0.0),
                                  color: widget.iconsColor,
                                  iconSize: 24,
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: widget.iconsColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPicCaptured = false;
                                      isVideoCaptured = false;
                                      controller.resumePreview();
                                    });
                                  },
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (showTabBar && !(controller?.value?.isRecordingVideo ?? false)) getTabView(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (isVideoType && (controller?.value?.isRecordingVideo ?? false))
                                      IconButton(
                                        padding: const EdgeInsets.all(0.0),
                                        icon: controller != null && controller.value.isRecordingPaused
                                            ? const Icon(Icons.play_arrow)
                                            : const Icon(Icons.pause),
                                        color: widget.iconsColor,
                                        onPressed: controller != null &&
                                                controller.value.isInitialized &&
                                                controller.value.isRecordingVideo
                                            ? (controller.value.isRecordingPaused)
                                                ? onResumeButtonPressed
                                                : onPauseButtonPressed
                                            : null,
                                      )
                                    else
                                      IconButton(
                                        iconSize: 16,
                                        padding: const EdgeInsets.all(0.0),
                                        icon: const Icon(Icons.perm_media_outlined),
                                        color: widget.iconsColor,
                                        onPressed: () async {
                                          Uint8List bytes;
                                          String filePath;
                                          if (!kIsWeb) {
                                            final PickedFile image = !isVideoType
                                                ? await ImagePicker().getImage(source: ImageSource.gallery)
                                                : await ImagePicker().getVideo(source: ImageSource.gallery);
                                            bytes = await image?.readAsBytes();
                                            filePath = image.path;
                                          } else {
                                            var result = await FilePicker.platform.pickFiles(type: FileType.media);
                                            if (result != null && result.files.isNotEmpty) {
                                              bytes = result.files.single.bytes;
                                              try {
                                                filePath = io.File.fromRawPath(bytes).path;
                                              } catch (ex, st) {
                                                /// TODO:- see
                                              }
                                            }
                                          }
                                          if (bytes != null && widget.onFileSubmit != null) {
                                            widget.onFileSubmit(filePath, bytes);
                                          }
                                          // var result= await FilePicker.platform.pickFiles(type: FileType.image, );
                                          // Uint8List bytes = result.files.single.bytes;
                                          // bytesList = [bytes];
                                          // getFile_Picker_onFilePicked(kIsWeb?bytesList:result.paths, result.names, bytesList);
                                        },
                                      ),
                                    SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.all(0.0),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                                        ),
                                        child: (isVideoType && (controller?.value?.isRecordingVideo ?? false))
                                            ? Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    borderRadius: BorderRadius.circular(32),
                                                    border: Border.all(width: 2.0, color: widget.iconsColor)),
                                                // padding: const EdgeInsets.all(6.0),
                                                child: Center(
                                                  child: Container(
                                                    width: 16,
                                                    height: 16,
                                                    decoration: BoxDecoration(
                                                      color: widget.videoRecordColor,
                                                      borderRadius: BorderRadius.circular(3),
                                                    ),
                                                  ),
                                                ))
                                            : Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    borderRadius: BorderRadius.circular(32),
                                                    border: Border.all(width: 2.0, color: widget.iconsColor)),
                                                padding: const EdgeInsets.all(4.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: isVideoType ? widget.videoRecordColor : widget.iconsColor,
                                                      borderRadius: BorderRadius.circular(32)),
                                                ),
                                              ),
                                        onPressed: () {
                                          if (controller != null) {
                                            if (isVideoType) {
                                              if (controller.value.isRecordingVideo) {
                                                onStopButtonPressed();
                                              } else if (controller.value.isInitialized) {
                                                onVideoRecordButtonPressed();
                                              }
                                            } else {
                                              onTakePictureButtonPressed();
                                            }
                                          }
                                        },
                                        onLongPress: () {
                                          if (controller != null) {
                                            if (!isVideoType) {
                                              setState(() {
                                                isVideoType = true;
                                              });
                                              onVideoRecordButtonPressed();
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      splashRadius: 12,
                                      padding: const EdgeInsets.all(0.0),
                                      color: widget.iconsColor,
                                      iconSize: 20,
                                      icon: Icon(
                                        getCameraLensIcon(cameraLensDirection),
                                        color: widget.iconsColor,
                                      ),
                                      onPressed: () {
                                        if (cameraLensDirection == CameraLensDirection.front) {
                                          cameraLensDirection = CameraLensDirection.back;
                                        } else {
                                          cameraLensDirection = CameraLensDirection.front;
                                        }
                                        setInitCamera(cameraLensDirection);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            )),
                if ((controller?.value?.isRecordingVideo ?? false))
                  Align(
                    alignment: Alignment.topCenter,
                    child: _TimerWidget(
                      isPause: controller?.value?.isRecordingPaused ?? false,
                    ),
                  )
              ],
      ),
    );
  }

  double moveLeft = 0;

  Widget getTabView() {
    double left = (widget.width - 24) / 2;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanEnd: (_) {
        moveLeft = 0;
      },
      onPanUpdate: (_) {
        moveLeft += (_.delta.dx);
        if (moveLeft >= 32) {
          moveLeft = 0;
          if (isVideoType) {
            setState(() {
              isVideoType = false;
            });
          }
        }
        if (moveLeft <= -32) {
          moveLeft = 0;
          if (!isVideoType) {
            setState(() {
              isVideoType = true;
            });
          }
        }
      },
      child: Container(
        width: widget.width - 24,
        alignment: Alignment.center,
        height: 32,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.only(left: isVideoType ? 0 : 36, right: isVideoType ? 36 : 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              getPhotosButton(),
              const SizedBox(
                width: 8,
              ),
              getVideoButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget getVideoButton() {
    return GestureDetector(
      child: getText("Video", isVideoType),
      onTap: () {
        setState(() {
          isVideoType = true;
        });
      },
    );
  }

  Widget getPhotosButton() {
    return GestureDetector(
      child: getText("Photo", !isVideoType),
      onTap: () {
        setState(() {
          isVideoType = false;
        });
      },
    );
  }

  Widget getText(String text, bool isSelected) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: SizedBox(
        width: 32,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                fontSize: 12.0,
                color: isSelected ? widget.selectedTextColor : widget.textColor,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Future initCamera(CameraDescription cameraDescription) async {
// create a CameraController
    controller = CameraController(cameraDescription, ResolutionPreset.high);
// Next, initialize the controller. This returns a Future.
    try {
      await controller.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  /// Returns a suitable camera icon for [direction].
  IconData getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear_outlined;
      case CameraLensDirection.front:
        return Icons.camera_front_outlined;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        throw ArgumentError('Unknown lens direction');
    }
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const CupertinoActivityIndicator(
        radius: 16,
      );
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          controller,
          child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: widget.allowZoomInZoomOut ? _handleScaleStart : null,
              onScaleUpdate: widget.allowZoomInZoomOut ? _handleScaleUpdate : null,
              onTapDown: (TapDownDetails details) => onViewFinderTap(details, constraints),
            );
          }),
        ),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale).clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller.setZoomLevel(_currentScale);
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    final VideoPlayerController localVideoController = videoController;

    if (localVideoController == null && imageFile == null) {
      return const SizedBox.shrink();
    }
    return (localVideoController == null)
        ? (
            // The captured image on the web contains a network-accessible URL
            // pointing to a location within the browser. It may be displayed
            // either with Image.network or Image.memory after loading the image
            // bytes to memory.
            kIsWeb ? Image.network(imageFile.path) : Image.file(File(imageFile.path)))
        : AspectRatio(
            aspectRatio: localVideoController.value.size != null ? localVideoController.value.aspectRatio : 1.0,
            child: kIsWeb ? blobUrlPlayer(source: videoFile.path) : VideoPlayer(localVideoController));
  }

  void onTakePictureButtonPressed() {
    takePicture().then((XFile file) {
      imageFile = file;
      videoController?.dispose();
      videoController = null;
      isPicCaptured = true;
      controller.pausePreview();
      if (mounted) {
        setState(() {});
        if (file != null) {
          // showInSnackBar('Picture saved to ${file.path}');
        }
      }
    });
  }

  void onFlashModeButtonPressed() {
    if (_flashModeControlRowAnimationController.value == 1) {
      _flashModeControlRowAnimationController.reverse();
    } else {
      _flashModeControlRowAnimationController.forward();
      _exposureModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onExposureModeButtonPressed() {
    if (_exposureModeControlRowAnimationController.value == 1) {
      _exposureModeControlRowAnimationController.reverse();
    } else {
      _exposureModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onFocusModeButtonPressed() {
    if (_focusModeControlRowAnimationController.value == 1) {
      _focusModeControlRowAnimationController.reverse();
    } else {
      _focusModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _exposureModeControlRowAnimationController.reverse();
    }
  }

  void onAudioModeButtonPressed() {
    enableAudio = !enableAudio;
    if (controller != null) {
      onNewCameraSelected(controller.description);
    }
  }

  Future<void> onCaptureOrientationLockButtonPressed() async {
    try {
      if (controller != null) {
        final CameraController cameraController = controller;
        if (cameraController.value.isCaptureOrientationLocked) {
          await cameraController.unlockCaptureOrientation();
          showInSnackBar('Capture orientation unlocked');
        } else {
          await cameraController.lockCaptureOrientation();
          showInSnackBar(
              'Capture orientation locked to ${cameraController.value.lockedCaptureOrientation.toString().split('.').last}');
        }
      }
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetExposureModeButtonPressed(ExposureMode mode) {
    setExposureMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Exposure mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetFocusModeButtonPressed(FocusMode mode) {
    setFocusMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Focus mode set to ${mode.toString().split('.').last}');
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((XFile file) {
      isVideoCaptured = true;
      controller.pausePreview();
      if (mounted) {
        setState(() {});
      }
      if (file != null) {
        // showInSnackBar('Video recorded to ${file.path}');
        videoFile = file;
        _startVideoPlayer();
      }
    });
  }

  Future<void> onPausePreviewButtonPressed() async {
    final CameraController cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isPreviewPaused) {
      await cameraController.resumePreview();
    } else {
      await cameraController.pausePreview();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
      // showInSnackBar('Video recording paused');
    });
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureMode(ExposureMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller.setExposureMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureOffset(double offset) async {
    if (controller == null) {
      return;
    }

    try {
      offset = await controller.setExposureOffset(offset);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFocusMode(FocusMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller.setFocusMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> _startVideoPlayer() async {
    if (videoFile == null) {
      return;
    }

    final VideoPlayerController vController =
    kIsWeb ? VideoPlayerController.network(videoFile.path) : VideoPlayerController.file(File(videoFile.path));

    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) {
          setState(() {});
        }
        videoController.removeListener(videoPlayerListener);
      }
    };
    vController.addListener(videoPlayerListener);
    await vController.setLooping(true);
    if (!kIsWeb) {
      await vController.initialize();
    }
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imageFile = null;
        videoController = vController;
      });
    }
    await vController.play();
  }

  Future<XFile> takePicture() async {
    final CameraController cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
      // showInSnackBar('Video recording resumed');
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile> stopVideoRecording() async {
    final CameraController cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    final CameraController cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    final CameraController cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  void scrUtilConversion() {
    ///BlupVersion check to make sure older Blup Versions are safe.
    // if (variables.blupVersion.toString() != "null") {
    //   widget.size = widget.size == null ? null : ScreenUtil().setWidth(widget.size);
    // }
  }

  @override
  void updateValues() {
    if (widget.onWebviewDefaultPropUpdate != null) {
      widget.onWebviewDefaultPropUpdate(
        widget.width,
        widget.height,
      );
    }
    if (widget.onWebviewExtraPropUpdate != null) {
      widget.onWebviewExtraPropUpdate();
    }
  }
}

/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.
// TODO(ianh): Remove this once we roll stable in  2021.
T _ambiguate<T>(T value) => value;

class blobUrlPlayer extends StatefulWidget {
  final String source;

  blobUrlPlayer({Key key, @required this.source}) : super(key: key);

  @override
  _blobUrlPlayerState createState() => _blobUrlPlayerState();
}

class _blobUrlPlayerState extends State<blobUrlPlayer> {
  // Widget _iframeWidget;
  final videoElement = html.VideoElement();

  @override
  void initState() {
    super.initState();
    videoElement
      ..src = widget.source
      ..autoplay = true
      ..controls = false
      ..loop = true
      ..style.border = 'none'
      ..style.height = '100%'
      ..style.width = '100%';

    // Allows Safari iOS to play the video inline
    videoElement.setAttribute('playsinline', 'true');

    // Set autoplay to false since most browsers won't autoplay a video unless it is muted
    videoElement.setAttribute('autoplay', 'false');

    //ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(widget.source, (int viewId) => videoElement);
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      key: UniqueKey(),
      viewType: widget.source,
    );
  }
}

class _TimerWidget extends StatefulWidget {

  const _TimerWidget({Key key,this.isPause}): super(key: key);

  final bool isPause;

  @override
  State<StatefulWidget> createState() => _TimerState();
}

class _TimerState extends State<_TimerWidget> {
  Timer timer;
  Duration duration;
  TextStyle textStyle = const TextStyle(fontWeight: FontWeight.w400, fontSize: 13.0, color: Colors.white,);

  @override
  void initState() {
    super.initState();
    duration = const Duration(milliseconds: 0);
    start();
  }


  @override
  void didUpdateWidget(_TimerWidget oldWidget) {
    if(widget.isPause != oldWidget.isPause) {
      if(widget.isPause) {
        stop();
      } else {
        start();
      }
    }
    super.didUpdateWidget(oldWidget);

  }

  void stop() {
    timer?.cancel();
    timer = null;
  }

  void start() {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
        oneSec,
            (Timer t) => setState(() {
          duration += oneSec;
        }));

  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(6.0),
        ),
        margin: const EdgeInsets.only(top: 2.0),
        padding: const EdgeInsets.only(top: 3.0, bottom: 3.0, left: 4.0, right: 4.0),
        child: Text(
          "${duration.inHours.toString().padLeft(2, '0')} : "
          "${(duration.inMinutes % 60).toString().padLeft(2, '0')} : "
          "${(duration.inSeconds % 60).toString().padLeft(2, '0')} ",
          style: textStyle,
        ));
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}