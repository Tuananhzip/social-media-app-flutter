import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaDetailScreen extends StatefulWidget {
  const MediaDetailScreen({super.key, required this.file});
  final File file;

  @override
  State<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends State<MediaDetailScreen> {
  VideoPlayerController? videoPlayerController;

  @override
  void initState() {
    super.initState();
    showMediaDetail();
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController?.pause(); // Pause the video when leaving the screen
    videoPlayerController?.dispose();
  }

  void showMediaDetail() {
    if (widget.file.path.toLowerCase().endsWith('.mp4')) {
      videoPlayerController = VideoPlayerController.file(widget.file)
        ..setLooping(true)
        ..initialize().then((value) {
          setState(() {});
          videoPlayerController?.play();
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media detail'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (videoPlayerController != null &&
              videoPlayerController!.value.isInitialized)
            buildVideo(videoPlayerController!)
          else if (!widget.file.path.toLowerCase().endsWith('.mp4'))
            buildImage(widget.file)
        ],
      ),
    );
  }

  Widget buildImage(File file) => Container(
        width: 400.0,
        height: 500.0,
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(border: Border.all(width: 2.0)),
        child: Image.file(
          file,
          fit: BoxFit.cover,
        ),
      );
  Widget buildVideo(VideoPlayerController videoController) => Container(
        width: 400.0,
        height: 500.0,
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(border: Border.all(width: 2.0)),
        child: videoController.value.isInitialized
            ? AspectRatio(
                aspectRatio: videoController.value.aspectRatio,
                child: VideoPlayer(videoController),
              )
            : const SizedBox(),
      );
}
