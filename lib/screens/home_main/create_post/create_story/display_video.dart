import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/screens/home_main/create_post/create_story/add_story_video_screen.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/audio_list.dart';
import 'package:social_media_app/utils/notifications_dialog.dart';
import 'package:video_player/video_player.dart';

class DisplayVideoScreen extends StatefulWidget {
  const DisplayVideoScreen({super.key, required this.videoPath});
  final String videoPath;

  @override
  State<DisplayVideoScreen> createState() => _DisplayVideoScreenState();
}

class _DisplayVideoScreenState extends State<DisplayVideoScreen> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;

  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = const Duration();
  Duration _position = const Duration();
  bool _isPlaying = false;
  bool _isMuted = false;
  String? _audioUrl;
  String? _audioName;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  Duration _videoDuration = const Duration();

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath));
    _controller.initialize().then((_) {
      _initialize();
      setState(() {});
    });
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });
    _playerStateSubscription =
        _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _chewieController.dispose();

    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _audioPlayer.dispose();
  }

  void _initialize() async {
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      aspectRatio: _controller.value.aspectRatio,
      showControls: false,
      autoPlay: true,
      looping: true,
      errorBuilder: (context, errorMessage) {
        return Center(
            child: Text(errorMessage,
                style: const TextStyle(color: Colors.white)));
      },
    );
    _videoDuration = _controller.value.duration;
    _chewieController.setVolume(_isMuted ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add music',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              if (_audioUrl != null && _audioName != null) {
                await _audioPlayer.play(AssetSource(_audioUrl!));
                await _audioPlayer.seek(_position);
              }
              await _chewieController.play();
            },
            icon: const Icon(Icons.refresh),
          ),
          TextButton(
            onPressed: _navigaToAddStory,
            child: Text(
              "Next",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _controller.value.isInitialized
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: Chewie(
                          controller: _chewieController,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10.0,
                      right: 10.0,
                      child: CircleAvatar(
                        radius: 20.0,
                        backgroundColor:
                            AppColors.primaryColor.withOpacity(0.6),
                        child: IconButton(
                          icon: Icon(
                            _isMuted ? Icons.volume_off : Icons.volume_up,
                            color: AppColors.backgroundColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _isMuted = !_isMuted;
                              _isMuted
                                  ? _controller.setVolume(0)
                                  : _controller.setVolume(1);
                            });
                          },
                        ),
                      ),
                    )
                  ],
                )
              : const CircularProgressIndicator(),
          SizedBox(
            height: 60,
            child: PageView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: AudioList.list.length,
              itemBuilder: (context, index) {
                final musicName =
                    AudioList.list[index].split('/').last.split('.').first;
                return ListTile(
                  tileColor: Theme.of(context).colorScheme.secondary,
                  trailing: index == AudioList.list.length - 1
                      ? null
                      : const Icon(Icons.arrow_right_rounded),
                  title: Text(musicName),
                  leading: const Icon(Icons.music_note_outlined),
                  onTap: () async {
                    setState(() {
                      _audioUrl = AudioList.list[index];
                      _audioName = musicName;
                      _position = Duration.zero;
                    });
                    await _audioPlayer.play(AssetSource(_audioUrl!));
                    await _chewieController.play();
                  },
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_audioUrl != null) ...[
                    CircleAvatar(
                      radius: 35,
                      child: IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                        onPressed: () async {
                          if (_isPlaying) {
                            await _audioPlayer.pause();
                            await _chewieController.play();
                          } else {
                            await _audioPlayer.play(AssetSource(_audioUrl!));
                            await _chewieController.play();
                          }
                        },
                      ),
                    ),
                    Flexible(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            'Playing: ${_audioUrl!.split('/').last.split('.').first}',
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.cancel_outlined),
                              onPressed: () {
                                _audioPlayer.stop();
                                setState(() {
                                  _audioUrl = null;
                                  _audioName = null;
                                  _position = Duration.zero;
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    Slider(
                      min: 0.0,
                      max: _duration.inSeconds.toDouble(),
                      value: _position.inSeconds.toDouble(),
                      onChanged: (value) async {
                        final position = Duration(seconds: value.toInt());
                        await _audioPlayer.seek(position);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatTime(_position),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primaryColor,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '${formatTime(_position)} - ${formatTime(_position + _videoDuration)}',
                          ),
                        ),
                        Text(
                          formatTime(_duration - _position),
                        ),
                      ],
                    ),
                    const Text('Your music time selected'),
                    Text(
                        'Based on video duration is ${_videoDuration.inMilliseconds / 1000.0}s'),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatTime(Duration duration) {
    final twoDigitMinutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final twoDigitSeconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _navigaToAddStory() async {
    if (_audioUrl == null && _audioName == null) {
      await _chewieController.pause();
      setState(() {});
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AddStoryVideoScreen(
                videoPath: widget.videoPath,
                isMuted: _isMuted,
              );
            },
          ),
        );
      }
    } else if (_duration - _position > _videoDuration) {
      await _audioPlayer.pause();
      await _chewieController.pause();
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AddStoryVideoScreen(
                videoPath: widget.videoPath,
                isMuted: _isMuted,
                audioUrl: _audioUrl,
                position: _position.inSeconds,
                audioName: _audioName,
              );
            },
          ),
        );
      }
    } else {
      DialogNotifications.notificationInfo(
          context,
          'Warning selected music time',
          'Please select music time less than ${_videoDuration.inMilliseconds / 1000.0}s');
    }
  }
}
