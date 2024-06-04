import 'package:flutter/material.dart';
import 'package:social_media_app/components/loading/loading_flickr.component.dart';
import 'package:video_player/video_player.dart';

class ThumbnailStoryVideoComponent extends StatefulWidget {
  const ThumbnailStoryVideoComponent({super.key, required this.videoPath});
  final String videoPath;

  @override
  State<ThumbnailStoryVideoComponent> createState() =>
      _ThumbnailStoryVideoComponentState();
}

class _ThumbnailStoryVideoComponentState
    extends State<ThumbnailStoryVideoComponent> {
  late VideoPlayerController _videoPlayerController;
  @override
  void initState() {
    super.initState();
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoPath))
          ..initialize().then((value) => setState(() {}));
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _videoPlayerController.value.isInitialized
        ? VideoPlayer(_videoPlayerController)
        : const LoadingFlickrComponent();
  }
}
