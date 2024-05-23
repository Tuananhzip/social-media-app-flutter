import 'package:flutter/material.dart';
import 'package:social_media_app/models/stories.dart';
import 'package:story_view/story_view.dart';

class StoryComponentScreen extends StatelessWidget {
  StoryComponentScreen({super.key, required this.stories});
  final List<Stories> stories;

  final StoryController _storyController = StoryController();

  @override
  Widget build(BuildContext context) {
    List<StoryItem> storyItems = stories.map((story) {
      final parts = story.mediaURL.split('.').last.split('?').first;
      if (parts == 'jpg' || parts == 'jpeg' || parts == 'png') {
        return StoryItem.pageImage(
          url: story.mediaURL,
          controller: _storyController,
          duration: const Duration(seconds: 15),
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
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: StoryView(
        storyItems: storyItems,
        controller: _storyController,
      ),
    );
  }
}
