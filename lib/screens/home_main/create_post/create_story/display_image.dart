import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/screens/home_main/create_post/create_story/add_story_screen.dart';
import 'package:social_media_app/utils/app_colors.dart';
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
  final List<String> _audioList = [
    'musics/better-day.mp3',
    'musics/separation.mp3',
    'musics/titanium.mp3',
    'musics/AnhSaoVaBauTroi.mp3',
    'musics/ChungTaCuaHienTai.mp3',
    'musics/EmDongY.mp3',
    'musics/HayTraoChoAnh.mp3',
    'musics/NgayDauTien.mp3',
    'musics/SeeTinh.mp3',
    'musics/WaitingForYou.mp3',
  ];
  String? _audioUrl;
  @override
  initState() {
    super.initState();
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add music to story',
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
              itemCount: _audioList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  tileColor: Theme.of(context).colorScheme.secondary,
                  trailing: index == _audioList.length - 1
                      ? null
                      : const Icon(Icons.arrow_right_rounded),
                  title:
                      Text(_audioList[index].split('/').last.split('.').first),
                  leading: const Icon(Icons.music_note_outlined),
                  onTap: () async {
                    setState(() {
                      _audioUrl = _audioList[index];
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
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                          'Playing: ${_audioUrl!.split('/').last.split('.').first}'),
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
                        Text(
                          '${formatTime(_position)} - ${formatTime(_position + const Duration(seconds: 15))}',
                        ),
                        Text(
                          formatTime(_duration - _position),
                        ),
                      ],
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text('Your music time selected')],
                    )
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
    if (_duration - _position > const Duration(seconds: 15)) {
      await _audioPlayer.pause();
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AddStoryScreen(
                image: widget.image,
                audioUrl: _audioUrl,
                position: _position.inSeconds,
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
