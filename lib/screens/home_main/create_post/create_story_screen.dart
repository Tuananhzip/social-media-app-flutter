import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/screens/home_main/create_post/display_image.dart';
import 'package:social_media_app/screens/home_main/create_post/display_video.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;
  bool _isRecording = false;
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
        ResolutionPreset.medium,
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
      if (!_isRecording) {
        await _initializeControllerFuture;
        final image = await _controller.takePicture();
        if (mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DisplayPictureScreen(imagePath: image.path),
            ),
          );
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
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DisplayVideoScreen(videoPath: video.path),
            ),
          );
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
      appBar: AppBar(
        centerTitle: true,
        title: const Text('New story'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: GestureDetector(
        onTap: () => _takeImage(),
        onLongPressStart: (_) => _startRecording(),
        onLongPressEnd: (_) => _endRecording(),
        child: FloatingActionButton(
          child: Icon(_isRecording
              ? Icons.stop_circle_outlined
              : Icons.play_circle_outlined),
          onPressed: () {},
        ),
      ),
    );
  }
}
