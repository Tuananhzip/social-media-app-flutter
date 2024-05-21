import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/utils/app_colors.dart';

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen(
      {super.key, required this.image, this.audioUrl, this.position});
  final Uint8List image;
  final int? position;
  final String? audioUrl;

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _playAudio();
  }

  void _playAudio() async {
    if (widget.audioUrl != null && widget.position != null) {
      _audioPlayer.play(AssetSource(widget.audioUrl!));
      _audioPlayer.seek(Duration(seconds: widget.position!));
      setState(() {
        _isPlaying = true;
      });
    }
    _timer = Timer(const Duration(seconds: 15), () {
      _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story'),
        actions: [
          IconButton(
            onPressed: _isPlaying ? null : _playAudio,
            icon: const Icon(Icons.refresh),
            color: _isPlaying ? AppColors.greyColor.withOpacity(0.5) : null,
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'Create',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.9,
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
    );
  }
}
