import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:logger/logger.dart';
import 'package:social_media_app/screens/home_main/create_post/create_story/display_image.dart';
import 'package:social_media_app/screens/home_main/create_post/create_story/display_video.dart';
import 'package:social_media_app/services/images/images.services.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/navigate.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final ImageServices _imageServices = ImageServices();
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;
  bool _isRecording = false;
  double _containerSize = 70.0;
  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initCamera();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> _initCamera() async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(
        cameras[selectedCameraIndex],
        ResolutionPreset.max,
      );
      _initializeControllerFuture = _controller.initialize();
      setState(() {});
    }
  }

  Future<void> _switchCamera() async {
    if (cameras.isNotEmpty) {
      selectedCameraIndex = (selectedCameraIndex + 1) % cameras.length;
      await _initCamera();
    }
  }

  Future<void> _takeImage() async {
    try {
      Logger().i('take image $_isRecording');
      if (!_isRecording) {
        await _initializeControllerFuture;
        final image = await _controller.takePicture();
        final uint8List =
            await _imageServices.fileToUint8List(File(image.path));
        if (mounted) {
          var editedImage = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageEditor(
                image: uint8List,
                savePath: image.path,
              ),
            ),
          );
          if (editedImage != null && mounted) {
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => DisplayPictureScreen(
            //       image: editedImage,
            //     ),
            //   ),
            // );
            navigateToScreenAnimationRightToLeft(
                context, DisplayPictureScreen(image: editedImage));
          }
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<void> _startRecording() async {
    try {
      await _initializeControllerFuture;
      setState(() {
        _isRecording = true;
      });
      await _controller.startVideoRecording();
    } catch (e) {
      // ignore: avoid_print
      print('_startRecording ---> $e');
    }
  }

  Future<void> _endRecording() async {
    try {
      if (_isRecording) {
        await _initializeControllerFuture;
        setState(() {
          _isRecording = false;
        });
        final video = await _controller.stopVideoRecording();
        if (mounted) {
          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (context) => DisplayVideoScreen(videoPath: video.path),
          //   ),
          // );
          navigateToScreenAnimationRightToLeft(
              context, DisplayVideoScreen(videoPath: video.path));
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print("_endRecording ---> $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: CameraPreview(_controller),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40.0, left: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.backgroundColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () => _takeImage(),
                      onLongPressStart: (_) {
                        setState(() {
                          _containerSize = 80.0;
                        });
                        _startRecording();
                      },
                      onLongPressEnd: (_) {
                        setState(() {
                          _containerSize = 70.0;
                        });
                        _endRecording();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeInOut,
                        height: _containerSize + 20,
                        width: _containerSize + 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.backgroundColor,
                            width: 5, // This creates the ring
                          ),
                        ),
                        child: Container(
                          height: _containerSize + 10,
                          width: _containerSize + 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.transparent,
                              width: 5, // This creates the ring
                            ),
                          ),
                          child: Container(
                            height: _containerSize,
                            width: _containerSize,
                            decoration: const BoxDecoration(
                              color: AppColors.backgroundColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0, right: 20.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => _switchCamera(),
                        icon: const Icon(Icons.switch_camera_outlined),
                      ),
                    ),
                  ),
                )
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
