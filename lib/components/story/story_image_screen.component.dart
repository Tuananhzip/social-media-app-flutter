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
import 'package:visibility_detector/visibility_detector.dart';

class StoryImageComponentScreen extends StatefulWidget {
  const StoryImageComponentScreen({
    super.key,
    required this.storyId,
  });
  final String storyId;

  @override
  State<StoryImageComponentScreen> createState() =>
      _StoryImageComponentScreenState();
}

class _StoryImageComponentScreenState extends State<StoryImageComponentScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioStoriesServices _audioStoriesServices = AudioStoriesServices();
  final StoryServices _storyServices = StoryServices();
  final UserServices _userServices = UserServices();
  Stories? _story;
  AudioStories? _audioStory;
  Users? _user;
  Timer? _timer;
  double _progress = 0.0;
  @override
  void initState() {
    super.initState();
    _getStory();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    _audioPlayer.dispose();
  }

  void _getAudio() async {
    _audioStory = await _audioStoriesServices.getAudioByStoryId(widget.storyId);
    if (_audioStory != null) {
      await _audioPlayer.play(AssetSource(_audioStory!.audioLink));
      await _audioPlayer.seek(Duration(seconds: _audioStory!.position));
    }
    _displayProgress();
  }

  void _getStory() async {
    _story = await _storyServices.getStoryById(widget.storyId);
    if (_story != null) {
      _getUserByUid(_story!.uid);
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
    _timer = Timer.periodic(const Duration(milliseconds: 50), (Timer timer) {
      if (timer.tick <= 300) {
        if (mounted) {
          setState(() {
            _progress = timer.tick / 300;
          });
        }
      } else {
        _audioPlayer.stop();
        timer.cancel();
      }
    });
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
                      setState(() {
                        _progress = 0.0;
                      });
                      _audioPlayer.stop();
                      _timer?.cancel();
                    }
                    if (info.visibleFraction == 1 && mounted) {
                      _timer?.cancel();
                      setState(() {
                        _progress = 0.0;
                      });
                      _getAudio();
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: CachedNetworkImage(
                          imageUrl: _story!.mediaURL,
                          imageBuilder: (context, imageProvider) {
                            return Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
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
                              onPressed: () {
                                _timer?.cancel();
                                setState(() {
                                  _progress = 0.0;
                                });
                                _getAudio();
                              },
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
        LinearProgressIndicator(
          value: _progress,
          backgroundColor: AppColors.primaryColor,
          minHeight: 6.0,
          valueColor:
              const AlwaysStoppedAnimation<Color>(AppColors.dangerColor),
        ),
      ],
    );
  }
}
