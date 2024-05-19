import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayerScreenComponent extends StatefulWidget {
  const VideoPlayerScreenComponent({super.key, required this.url});
  final String url;

  @override
  State<VideoPlayerScreenComponent> createState() =>
      _VideoPlayerScreenComponentState();
}

class _VideoPlayerScreenComponentState extends State<VideoPlayerScreenComponent>
    with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoIntialized = false;
  @override
  void initState() {
    super.initState();
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _videoPlayerController.initialize().then((_) {
      _initialize();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
    _chewieController?.dispose();
  }

  void _initialize() async {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      errorBuilder: (context, errorMessage) {
        return Center(
            child: Text(errorMessage,
                style: const TextStyle(color: Colors.white)));
      },
    );
    _chewieController?.setVolume(0.0);
    setState(() {
      _isVideoIntialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _isVideoIntialized
        ? VisibilityDetector(
            key: Key(_videoPlayerController.dataSource.toString()),
            onVisibilityChanged: (info) {
              if (info.visibleFraction * 100 > 50) {
                _chewieController?.play();
              } else {
                _chewieController?.pause();
              }
            },
            child: Chewie(
              controller: _chewieController!,
            ),
          )
        : Stack(
            children: [
              Container(
                color: Theme.of(context).colorScheme.primary,
              ),
              const Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.play_circle_outline_rounded,
                  color: Colors.white,
                  size: 50.0,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: VideoProgressIndicator(
                  _videoPlayerController,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    backgroundColor: Colors.grey.withOpacity(0.5),
                    playedColor: Colors.red,
                  ),
                ),
              ),
            ],
          );
  }

  @override
  bool get wantKeepAlive => true;
}
