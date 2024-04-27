import 'package:flutter/material.dart';
import 'package:social_media_app/components/loading/overlay_loading.component.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerComponent extends StatefulWidget {
  const VideoPlayerComponent({super.key, required this.url});
  final String url;

  @override
  State<VideoPlayerComponent> createState() => _VideoPlayerComponentState();
}

class _VideoPlayerComponentState extends State<VideoPlayerComponent> {
  late VideoPlayerController _controller;
  late VoidCallback _listener;
  bool _isShowing = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {});
      });
    _listener = () {
      if (_controller.value.position == _controller.value.duration) {
        Navigator.of(context).pop();
      }
    };
    _controller.addListener(_listener);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _controller.removeListener(_listener);
  }

  void _handlePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {
      _isShowing = !_isShowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Stack(
        children: [
          if (_controller.value.isInitialized)
            GestureDetector(
              onTap: _handlePlayPause,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: VideoPlayer(_controller),
              ),
            ),
          if (_controller.value.isInitialized && _isShowing)
            Center(
              child: IconButton(
                onPressed: _handlePlayPause,
                icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 50,
                ),
                color: Colors.white,
              ),
            ),
          if (_controller.value.isBuffering || !_controller.value.isInitialized)
            const OverlayLoadingWidget(),
          Positioned(
            top: 50,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
