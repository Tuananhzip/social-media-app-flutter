import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:marquee/marquee.dart';
import 'package:social_media_app/components/loading/loading_flickr.component.dart';
import 'package:social_media_app/models/audio_stories.dart';
import 'package:social_media_app/models/stories.dart';
import 'package:social_media_app/services/audios/audio_stories.service.dart';
import 'package:social_media_app/services/featuredStories/featured_story.service.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:story_view/story_view.dart';
import 'package:video_player/video_player.dart';

class StoryComponentScreen extends StatefulWidget {
  const StoryComponentScreen({super.key, required this.featuredStoryId});
  final String featuredStoryId;

  @override
  State<StoryComponentScreen> createState() => _StoryComponentScreenState();
}

class _StoryComponentScreenState extends State<StoryComponentScreen> {
  final StoryController _storyController = StoryController();
  final FeaturedStoryServices _featuredStoryServices = FeaturedStoryServices();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioStoriesServices _audioStoriesServices = AudioStoriesServices();
  final List<Stories> _stories = [];
  final List<AudioStories> _audios = [];

  @override
  void initState() {
    super.initState();
    _fetchStories();
  }

  @override
  void dispose() {
    super.dispose();
    _storyController.dispose();
    _audioPlayer.dispose();
  }

  void _fetchStories() async {
    final docStories = await _featuredStoryServices
        .getListStoryByFeaturedStoryId(widget.featuredStoryId);
    if (docStories.isEmpty) {
      Logger().i('No stories found');
      return;
    }
    List<Stories> stories = docStories
        .map((story) => Stories.fromMap(story.data() as Map<String, dynamic>))
        .toList();
    final idStories = docStories.map((story) => story.id).toList();
    if (stories.isNotEmpty && idStories.isNotEmpty) {
      _getAudioStories(idStories);
      setState(() {
        _stories.addAll(stories);
      });
    }
  }

  void _getAudioStories(List<String> storyIds) async {
    final futures = storyIds
        .map((storyId) => _audioStoriesServices.getAudioByStoryId(storyId));
    final futureAudios = await Future.wait(futures);
    final audios = futureAudios.map((audio) => audio ?? AudioStories.empty());
    setState(() {
      _audios.addAll(audios);
    });
  }

  void _onStoryShow(StoryItem storyItem, int index) {
    Logger().f("$index - ${_audios[index].audioLink}");
    if (index < _audios.length) {
      if (_audios[index].audioLink != '') {
        _audioPlayer.stop();
        _audioPlayer.play(AssetSource(_audios[index].audioLink));
        _audioPlayer.seek(Duration(seconds: _audios[index].position));
      } else {
        _audioPlayer.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<StoryItem> storyItems = _stories.map((story) {
      final parts = story.mediaURL.split('.').last.split('?').first;
      if (parts == 'jpg' || parts == 'jpeg' || parts == 'png') {
        return StoryItem.pageImage(
          url: story.mediaURL,
          controller: _storyController,
          duration: const Duration(seconds: 15),
          imageFit: BoxFit.cover,
        );
      } else if (parts == 'mp4') {
        return StoryItem.pageVideo(
          story.mediaURL,
          controller: _storyController,
        );
      } else {
        return StoryItem.text(
          title: 'Error',
          backgroundColor: Colors.redAccent,
        );
      }
    }).toList();
    if (storyItems.isEmpty || _audios.isEmpty) {
      return const Center(
        child: LoadingFlickrComponent(),
      );
    } else {
      return Scaffold(
        body: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: StoryView(
                storyItems: storyItems,
                controller: _storyController,
                onComplete: () => Navigator.pop(context),
                onStoryShow: _onStoryShow,
              ),
            ),
            Positioned(
              top: 60.0,
              right: 30.0,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.close,
                  color: AppColors.primaryColor,
                  size: 30.0,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
// Nếu gặp lỗi này khi pop thì đó là lỗi của package *không thể catch được lỗi đó ở đâu vì nó là lỗi của package
// E/flutter (11211): [ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception: Bad state: No element
// E/flutter (11211): #0      Stream.first.<anonymous closure> (dart:async/stream.dart:1583:9)
// E/flutter (11211): #1      _RootZone.runGuarded (dart:async/zone.dart:1582:10)
// E/flutter (11211): #2      _BufferingStreamSubscription._sendDone.sendDone (dart:async/stream_impl.dart:392:13)
// E/flutter (11211): #3      _BufferingStreamSubscription._sendDone (dart:async/stream_impl.dart:402:7)
// E/flutter (11211): #4      _BufferingStreamSubscription._close (dart:async/stream_impl.dart:291:7)
// E/flutter (11211): #5      _ForwardingStream._handleDone (dart:async/stream_pipe.dart:99:10)
// E/flutter (11211): #6      _ForwardingStreamSubscription._handleDone (dart:async/stream_pipe.dart:161:13)
// E/flutter (11211): #7      _RootZone.runGuarded (dart:async/zone.dart:1582:10)
// E/flutter (11211): #8      _BufferingStreamSubscription._sendDone.sendDone (dart:async/stream_impl.dart:392:13)
// E/flutter (11211): #9      _BufferingStreamSubscription._sendDone (dart:async/stream_impl.dart:402:7)
// E/flutter (11211): #10     _DelayedDone.perform (dart:async/stream_impl.dart:534:14)
// E/flutter (11211): #11     _PendingEvents.handleNext (dart:async/stream_impl.dart:620:11)
// E/flutter (11211): #12     _PendingEvents.schedule.<anonymous closure> (dart:async/stream_impl.dart:591:7)
// E/flutter (11211): #13     _microtaskLoop (dart:async/schedule_microtask.dart:40:21)
// E/flutter (11211): #14     _startMicrotaskLoop (dart:async/schedule_microtask.dart:49:5)