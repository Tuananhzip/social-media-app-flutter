import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:social_media_app/components/loading/loading_flickr.component.dart';
import 'package:social_media_app/components/loading/loading_wave_dots.component.dart';
import 'package:social_media_app/screens/home_main/home_main.dart';
import 'package:social_media_app/services/audios/audio_stories.service.dart';
import 'package:social_media_app/services/stories/story.service.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/my_enum.dart';
import 'package:social_media_app/utils/notifications_dialog.dart';
import 'package:video_player/video_player.dart';

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
  late VideoPlayerController _videoPlayerController;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final StoryServices _storyServices = StoryServices();
  final AudioStoriesServices _audioStoriesServices = AudioStoriesServices();
  bool _isPlaying = false;
  bool _isUploaded = false;
  Timer? _timer;
  double _progress = 0.0;
  Duration _videoDuration = const Duration();
  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _initializeVideo() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath))
      ..setLooping(true)
      ..setVolume(widget.isMuted ? 0 : 1)
      ..initialize().then((_) {
        _videoDuration = _videoPlayerController.value.duration;
        _refresh();
      });
  }

  void _playAudio() async {
    await _audioPlayer.play(AssetSource(widget.audioUrl!));
    await _audioPlayer.seek(Duration(seconds: widget.position!));
    await _videoPlayerController.play();
    setState(() {});
  }

  void _playVideo() async {
    await _videoPlayerController.play();
    await _videoPlayerController.seekTo(Duration.zero);
    setState(() {});
  }

  void _refresh() {
    _playVideo();
    _displayProgress();
    if (widget.audioUrl != null &&
        widget.position != null &&
        widget.audioName != null) {
      _playAudio();
    }
  }

  void _displayProgress() {
    setState(() {
      _isPlaying = true;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      double elapsedMiliseconds = timer.tick * 100;
      if (elapsedMiliseconds <= _videoDuration.inMilliseconds) {
        setState(() {
          _progress = elapsedMiliseconds / _videoDuration.inMilliseconds;
        });
      } else {
        setState(() {
          _isPlaying = false;
          _progress = 0.0;
        });
        _videoPlayerController.pause();
        _audioPlayer.stop();
        timer.cancel();
      }
    });
  }

  void _addStory() async {
    setState(() {
      _isUploaded = true;
    });
    final storyId = await _storyServices.addStory(
        video: widget.videoPath, volume: !widget.isMuted);
    if (storyId != null) {
      if (widget.audioUrl != null &&
          widget.position != null &&
          widget.audioName != null) {
        await _audioStoriesServices.addAudioStory(
          storyId,
          widget.audioName!,
          widget.audioUrl!,
          widget.position!,
        );
      }
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const HomeMain(
                fragment: Fragments.profileScreen,
              ),
            ),
            (route) => false);
        DialogNotifications.notificationSuccess(
          context,
          'Story added successfully',
          'Waiting upload story in a moment',
        );
      }
    } else {
      Logger().e('Failed to add story');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
            !_isUploaded, // Hide back button if _isUploaded is true
        title: const Text('Story'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isPlaying ? null : _refresh,
            icon: const Icon(Icons.refresh),
            color: _isPlaying ? AppColors.greyColor.withOpacity(0.5) : null,
          ),
          TextButton(
            onPressed: _isUploaded ? null : _addStory,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.blackColor,
                          blurRadius: 5,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: _videoPlayerController.value.isInitialized
                        ? VideoPlayer(_videoPlayerController)
                        : const LoadingFlickrComponent(),
                  ),
                  _isUploaded
                      ? const LoadingWaveDotsComponent()
                      : const SizedBox.shrink(),
                ],
              ),
            ),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: AppColors.primaryColor,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.dangerColor),
            ),
          ],
        ),
      ),
    );
  }
}
