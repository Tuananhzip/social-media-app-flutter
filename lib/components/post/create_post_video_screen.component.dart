import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CreatePostVideoScreenComponent extends StatefulWidget {
  const CreatePostVideoScreenComponent({super.key, required this.file});
  final File file;

  @override
  State<CreatePostVideoScreenComponent> createState() =>
      _CreatePostVideoScreenComponentState();
}

class _CreatePostVideoScreenComponentState
    extends State<CreatePostVideoScreenComponent> {
  late VideoPlayerController _videoPlayerController;
  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400.0,
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _videoPlayerController.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController),
              )
            : const SizedBox(),
      ),
    );
  }
}
