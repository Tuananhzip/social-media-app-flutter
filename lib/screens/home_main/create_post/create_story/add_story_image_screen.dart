import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:social_media_app/components/loading/overlay_loading.component.dart';
import 'package:social_media_app/screens/home_main/home_main.dart';
import 'package:social_media_app/services/audios/audio_stories.service.dart';
import 'package:social_media_app/services/stories/story.service.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/notifications_dialog.dart';

class AddStoryImageScreen extends StatefulWidget {
  const AddStoryImageScreen(
      {super.key,
      required this.image,
      this.audioUrl,
      this.position,
      this.audioName});
  final Uint8List image;
  final int? position;
  final String? audioUrl;
  final String? audioName;

  @override
  State<AddStoryImageScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryImageScreen> {
  final StoryServices _storyServices = StoryServices();
  final AudioStoriesServices _audioStoriesServices = AudioStoriesServices();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isUploaded = false;
  Timer? _timer;
  double _progress = 0.0;
  @override
  void initState() {
    super.initState();
    if (widget.audioUrl != null && widget.position != null) {
      _playAudio();
    } else {
      _displayProgress();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _timer?.cancel();
  }

  void _playAudio() async {
    if (widget.audioUrl != null && widget.position != null) {
      _audioPlayer.play(AssetSource(widget.audioUrl!));
      _audioPlayer.seek(Duration(seconds: widget.position!));
    }
    _displayProgress();
  }

  void _displayProgress() {
    setState(() {
      _isPlaying = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (timer.tick <= 15) {
        setState(() {
          _progress = timer.tick / 15;
        });
      } else {
        _audioPlayer.stop();
        setState(() {
          _isPlaying = false;
          _progress = 0.0;
        });
        timer.cancel();
      }
    });
  }

  void _addStory() async {
    setState(() {
      _isUploaded = true;
    });
    final storyId = await _storyServices.addStory(widget.image);
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
              builder: (context) => const HomeMain(),
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
            onPressed: _isPlaying ? null : _playAudio,
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
                      image: DecorationImage(
                        image: MemoryImage(widget.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  _isUploaded
                      ? const OverlayLoadingWidget()
                      : const SizedBox.shrink(),
                ],
              ),
            ),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: AppColors.greyColor,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
