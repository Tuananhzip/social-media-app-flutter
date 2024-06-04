import 'dart:io';

import 'package:flutter/material.dart';
import 'package:social_media_app/components/loading/loading_flickr.component.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:video_player/video_player.dart';

class CreatePostVideoPlayerScreenComponent extends StatefulWidget {
  const CreatePostVideoPlayerScreenComponent(
      {super.key, required this.videoPath});
  final File videoPath;

  @override
  State<CreatePostVideoPlayerScreenComponent> createState() =>
      _CreatePostVideoPlayerScreenComponentState();
}

class _CreatePostVideoPlayerScreenComponentState
    extends State<CreatePostVideoPlayerScreenComponent> {
  late VideoPlayerController _videoPlayerController;
  bool isInitialized = false;
  bool isMuted = false;
  @override
  void initState() {
    super.initState();
    initVideo();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  initVideo() {
    _videoPlayerController = VideoPlayerController.file(widget.videoPath)
      ..setLooping(true)
      ..setVolume(isMuted ? 0 : 1)
      ..initialize().then((value) {
        _videoPlayerController.play();
        setState(() {
          isInitialized = true;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isInitialized
          ? Stack(
              children: [
                GestureDetector(
                  onDoubleTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    margin: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: VideoPlayer(_videoPlayerController),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 42, right: 42),
                    child: CircleAvatar(
                      backgroundColor:
                          AppColors.backgroundColor.withOpacity(0.5),
                      child: IconButton(
                        icon: Icon(
                          isMuted ? Icons.volume_off : Icons.volume_up,
                          color: AppColors.backgroundColor,
                        ),
                        onPressed: () {
                          setState(() {
                            isMuted = !isMuted;
                            _videoPlayerController.setVolume(isMuted ? 0 : 1);
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50, left: 24),
                    child: CircleAvatar(
                      backgroundColor:
                          AppColors.backgroundColor.withOpacity(0.5),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.backgroundColor,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: VideoProgressIndicator(
                    _videoPlayerController,
                    allowScrubbing: false,
                  ),
                )
              ],
            )
          : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingFlickrComponent(),
                SizedBox(height: 20),
                Text('Loading'),
              ],
            ),
    );
  }
}
