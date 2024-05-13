import 'package:flutter/material.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPostScreen extends StatefulWidget {
  const VideoPostScreen({super.key, required this.controller});
  final VideoPlayerController controller;

  @override
  State<VideoPostScreen> createState() => _VideoPostScreenState();
}

class _VideoPostScreenState extends State<VideoPostScreen> {
  bool _isVolume = false;
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.controller.dataSource),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage > 50) {
          widget.controller.play();
        } else {
          widget.controller.pause();
        }
      },
      child: Stack(
        children: [
          VideoPlayer(widget.controller),
          Positioned(
            bottom: 20,
            right: 20,
            child: StatefulBuilder(
              builder: (context, setState) {
                return CircleAvatar(
                  backgroundColor: AppColors.blackColor.withOpacity(0.4),
                  child: IconButton(
                    icon: Icon(
                      color: AppColors.backgroundColor,
                      _isVolume
                          ? Icons.volume_up_outlined
                          : Icons.volume_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _isVolume = !_isVolume;
                        widget.controller.setVolume(_isVolume ? 1.0 : 0.0);
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
