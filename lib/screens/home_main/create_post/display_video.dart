import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class DisplayVideoScreen extends StatefulWidget {
  const DisplayVideoScreen({super.key, required this.videoPath});
  final String videoPath;

  @override
  State<DisplayVideoScreen> createState() => _DisplayVideoScreenState();
}

class _DisplayVideoScreenState extends State<DisplayVideoScreen> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath));
    _controller.initialize().then((_) {
      _initialize();
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _chewieController?.dispose();
  }

  void _initialize() async {
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: true,
      aspectRatio: _controller.value.aspectRatio,
      errorBuilder: (context, errorMessage) {
        return Center(
            child: Text(errorMessage,
                style: const TextStyle(color: Colors.white)));
      },
    );
    _chewieController?.setVolume(0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Video')),
      body: Container(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Chewie(
                  controller: _chewieController!,
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
