import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/services/audios/audio_stories.service.dart';
import 'package:social_media_app/services/stories/story.service.dart';
import 'package:social_media_app/utils/app_colors.dart';

class AddStoryVideoScreen extends StatefulWidget {
  const AddStoryVideoScreen(
      {super.key,
      required this.videoPath,
      required this.isMuted,
      this.position,
      this.audioUrl,
      this.audioName});
  final String videoPath;
  final bool isMuted;
  final int? position;
  final String? audioUrl;
  final String? audioName;

  @override
  State<AddStoryVideoScreen> createState() => _AddStoryVideoScreenState();
}

class _AddStoryVideoScreenState extends State<AddStoryVideoScreen> {
  final StoryServices _storyServices = StoryServices();
  final AudioStoriesServices _audioStoriesServices = AudioStoriesServices();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isUploaded = false;
  Timer? _timer;
  double _progress = 0.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.refresh),
            color: _isPlaying ? AppColors.greyColor.withOpacity(0.5) : null,
          ),
          TextButton(
            onPressed: () {},
            child: _isUploaded
                ? Text(
                    'Creating...',
                    style: TextStyle(
                      color: AppColors.greyColor.withOpacity(0.5),
                    ),
                  )
                : Text(
                    'Create',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
          ),
        ],
      ),
    );
  }
}
