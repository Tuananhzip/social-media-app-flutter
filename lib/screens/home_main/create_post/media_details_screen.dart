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
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _showMediaDetail();
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController?.pause(); // Pause the video when leaving the screen
    _videoPlayerController?.dispose();
  }

  void _showMediaDetail() {
    if (widget.file.path.toLowerCase().endsWith('.mp4')) {
      _videoPlayerController = VideoPlayerController.file(widget.file)
        ..setLooping(true)
        ..initialize().then((value) {
          setState(() {});
          _videoPlayerController?.play();
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
          if (_videoPlayerController != null &&
              _videoPlayerController!.value.isInitialized)
            _buildVideo(_videoPlayerController!)
          else if (!widget.file.path.toLowerCase().endsWith('.mp4'))
            _buildImage(widget.file)
        ],
      ),
    );
  }

  Widget _buildImage(File file) => Container(
        width: 400.0,
        height: 600.0,
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(
            file,
            fit: BoxFit.cover,
          ),
        ),
      );
  Widget _buildVideo(VideoPlayerController videoController) => Container(
        width: 400.0,
        height: 600.0,
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: videoController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: videoController.value.aspectRatio,
                  child: VideoPlayer(videoController),
                )
              : const SizedBox(),
        ),
      );
}
