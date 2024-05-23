import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/screens/home_main/create_post/create_story/add_story_image_screen.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/audio_list.dart';
import 'package:social_media_app/utils/notifications_dialog.dart';

class DisplayPictureScreen extends StatefulWidget {
  const DisplayPictureScreen({super.key, required this.image});
  final Uint8List image;

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = const Duration();
  Duration _position = const Duration();
  bool _isPlaying = false;
  String? _audioUrl;
  String? _audioName;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  initState() {
    super.initState();
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
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _audioPlayer.dispose();
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
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 0,
            ),
            child: TextButton(
              onPressed: _navigaToAddStory,
              child: Text(
                "Next",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.5,
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
          ),
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
                          } else {
                            await _audioPlayer.play(AssetSource(_audioUrl!));
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
                            '${formatTime(_position)} - ${formatTime(_position + const Duration(seconds: 15))}',
                          ),
                        ),
                        Text(
                          formatTime(_duration - _position),
                        ),
                      ],
                    ),
                    const Text('Your music time selected'),
                    const Text('Defaut story image time is 15s'),
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return AddStoryImageScreen(
              image: widget.image,
            );
          },
        ),
      );
    } else if (_duration - _position > const Duration(seconds: 15)) {
      await _audioPlayer.pause();
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AddStoryImageScreen(
                image: widget.image,
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
          'Please select music time less than 15s');
    }
  }
}
