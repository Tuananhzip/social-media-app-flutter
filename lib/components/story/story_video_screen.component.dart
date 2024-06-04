import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:social_media_app/components/loading/loading_flickr.component.dart';
import 'package:social_media_app/models/audio_stories.dart';
import 'package:social_media_app/models/stories.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/screens/home_main/search/profile_users_screen.dart';
import 'package:social_media_app/services/audios/audio_stories.service.dart';
import 'package:social_media_app/services/stories/story.service.dart';
import 'package:social_media_app/services/users/user.services.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/navigate.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class StoryVideoComponentScreen extends StatefulWidget {
  const StoryVideoComponentScreen({super.key, required this.storyId});
  final String storyId;

  @override
  State<StoryVideoComponentScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<StoryVideoComponentScreen> {
  late VideoPlayerController _videoPlayerController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioStoriesServices _audioStoriesServices = AudioStoriesServices();
  final StoryServices _storyServices = StoryServices();
  final UserServices _userServices = UserServices();
  Stories? _story;
  AudioStories? _audioStory;
  Users? _user;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getStory();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _getAudio() async {
    final audioStory =
        await _audioStoriesServices.getAudioByStoryId(widget.storyId);
    if (audioStory != null) {
      setState(() {
        _audioStory = audioStory;
      });
      await _audioPlayer.play(AssetSource(_audioStory!.audioLink));
      await _audioPlayer.seek(Duration(seconds: _audioStory!.position));
      await _videoPlayerController.play();
    }
  }

  void _getStory() async {
    _story = await _storyServices.getStoryById(widget.storyId);
    if (_story != null) {
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(_story!.mediaURL))
            ..setVolume(_story!.volume! ? 1 : 0)
            ..initialize().then((_) {
              _getUserByUid(_story!.uid);
              _getAudio();
              _videoPlayerController.play();
              _displayProgress();
              setState(() {});
            });
    }
  }

  void _getUserByUid(String uid) async {
    final user = await _userServices.getUserDetailsByID(uid);
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  void _displayProgress() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      if (_videoPlayerController.value.position ==
          _videoPlayerController.value.duration) {
        _audioPlayer.stop();
        timer.cancel();
      }
    });
  }

  void _refresh() async {
    await _videoPlayerController.play();
    await _videoPlayerController.seekTo(Duration.zero);
    _getAudio();
    _displayProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _story != null
              ? VisibilityDetector(
                  key: Key(_story!.mediaURL),
                  onVisibilityChanged: (info) {
                    if (info.visibleFraction == 0 && mounted) {
                      _videoPlayerController.pause();
                      _audioPlayer.stop();
                      _timer?.cancel();
                    }
                    if (info.visibleFraction == 1 && mounted) {
                      _refresh();
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: _videoPlayerController.value.isInitialized
                            ? VideoPlayer(_videoPlayerController)
                            : const SizedBox.shrink(),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 42.0, right: 20.0),
                          child: CircleAvatar(
                            backgroundColor:
                                AppColors.backgroundColor.withOpacity(0.5),
                            child: IconButton(
                              onPressed: _refresh,
                              icon: const Icon(
                                Icons.refresh,
                                color: AppColors.backgroundColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _user != null && _story != null
                          ? Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 60.0, left: 20.0),
                                child: GestureDetector(
                                  onTap: () =>
                                      navigateToScreenAnimationRightToLeft(
                                          context,
                                          ProfileUsersScreen(
                                            user: _user!,
                                            uid: _story!.uid,
                                          )),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 15,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                          _user!.imageProfile!,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          _user?.username ?? 'unknown',
                                          style: const TextStyle(
                                            color: AppColors.backgroundColor,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                      _audioStory != null
                          ? Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 40.0, left: 20.0),
                                child: SizedBox(
                                  width: 220.0,
                                  height: 24.0,
                                  child: Marquee(
                                    text: _audioStory!.audioName,
                                    style: const TextStyle(
                                      color: AppColors.backgroundColor,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    blankSpace: 20.0,
                                    accelerationCurve: Curves.linear,
                                    decelerationCurve: Curves.easeOut,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                )
              : const LoadingFlickrComponent(),
        ),
        _story != null
            ? VideoProgressIndicator(
                _videoPlayerController,
                allowScrubbing: false,
                colors: const VideoProgressColors(
                  playedColor: AppColors.dangerColor,
                  bufferedColor: AppColors.primaryColor,
                  backgroundColor: AppColors.greyColor,
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
