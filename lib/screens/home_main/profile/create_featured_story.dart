import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/loading/loading_flickr.component.dart';
import 'package:social_media_app/components/story/thumbnail_story_video.component.dart';
import 'package:social_media_app/models/stories.dart';
import 'package:social_media_app/screens/home_main/home_main.dart';
import 'package:social_media_app/screens/home_main/profile/profile_screen.dart';
import 'package:social_media_app/services/featuredStories/featured_story.service.dart';
import 'package:social_media_app/services/stories/story.service.dart';
import 'package:social_media_app/utils/my_enum.dart';
import 'package:social_media_app/utils/notifications_dialog.dart';

class CreateFeaturedStoryScreen extends StatefulWidget {
  const CreateFeaturedStoryScreen({super.key, required this.selectedStories});
  final List<String> selectedStories;

  @override
  State<CreateFeaturedStoryScreen> createState() =>
      _CreateFeaturedStoryScreenState();
}

class _CreateFeaturedStoryScreenState extends State<CreateFeaturedStoryScreen> {
  final StoryServices _storyServices = StoryServices();
  final TextEditingController _descriptionController = TextEditingController();
  final FeaturedStoryServices _featuredStoryServices = FeaturedStoryServices();
  Stories? lastStory;
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<Widget> _getLastStory() async {
    lastStory = await _storyServices.getStoryById(widget.selectedStories.last);
    if (lastStory != null) {
      if (lastStory?.mediaType == MediaTypeEnum.image.name) {
        return CircleAvatar(
          radius: 100.0,
          backgroundImage: CachedNetworkImageProvider(lastStory!.mediaURL),
        );
      } else {
        return CircleAvatar(
          radius: 100.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100.0),
            child: ThumbnailStoryVideoComponent(
              videoPath: lastStory!.mediaURL,
            ),
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }

  void _onCreateFeaturedStory(
      String featuredStoryDescription, String imageUrl) async {
    setState(() {
      _isLoading = true;
    });
    await _featuredStoryServices
        .addFeaturedStory(
            featuredStoryDescription, imageUrl, widget.selectedStories)
        .then((_) {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const HomeMain(),
          ),
          (route) => false);
      DialogNotifications.notificationSuccess(
        context,
        'Featured story added successfully',
        'Waiting upload featured story in a moment',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.selectedStories.length} Stories Selected',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 64.0),
                child: Text(
                  'Featured story',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              FutureBuilder<Widget>(
                future: _getLastStory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(
                      radius: 100.0,
                      child: LoadingFlickrComponent(),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return snapshot.data!;
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 250.0,
                  child: TextField(
                    controller: _descriptionController,
                    maxLength: 20,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      label: Text(
                        'Add Description',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),
                ),
              ),
              _isLoading
                  ? const LoadingFlickrComponent()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlinedButton(
                        onPressed: () => _onCreateFeaturedStory(
                          _descriptionController.text.trim(),
                          lastStory!.mediaURL,
                        ),
                        child: Text(
                          'Create',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
