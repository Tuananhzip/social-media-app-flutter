import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:social_media_app/components/story/thumbnail_story_video.component.dart';
import 'package:social_media_app/models/stories.dart';
import 'package:social_media_app/screens/home_main/profile/create_featured_story.dart';
import 'package:social_media_app/services/stories/story.service.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/my_enum.dart';
import 'package:social_media_app/utils/navigate.dart';

class AddFeaturedStoryScreen extends StatefulWidget {
  const AddFeaturedStoryScreen({super.key});

  @override
  State<AddFeaturedStoryScreen> createState() => _AddFeaturedStoryScreenState();
}

class _AddFeaturedStoryScreenState extends State<AddFeaturedStoryScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final StoryServices _storyServices = StoryServices();
  List<Stories> _stories = [];
  List<String> _idStories = [];
  final List<String> _selectedStories = [];

  @override
  void initState() {
    super.initState();
    _fetchStories();
  }

  void _fetchStories() async {
    await _storyServices.getStoryByUserId(currentUser!.uid).then((value) {
      setState(() {
        _idStories = value.map((story) => story.id).toList();
        _stories =
            value.map((story) => Stories.fromMap(story.data() as Map)).toList();
      });
    });
    Logger().i(_idStories);
  }

  void _selectStory(String storyId) {
    setState(() {
      if (_selectedStories.contains(storyId)) {
        _selectedStories.remove(storyId);
      } else {
        _selectedStories.add(storyId);
      }
    });
    Logger().i(_selectedStories);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Text('Back'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Add Featured Story',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: _selectedStories.isNotEmpty
                  ? () {
                      navigateToScreenAnimationRightToLeft(
                        context,
                        const CreateFeaturedStoryScreen(),
                      );
                    }
                  : null,
              icon: _selectedStories.isNotEmpty
                  ? const Text('Next')
                  : const Text(
                      'Next',
                      style: TextStyle(color: AppColors.greyColor),
                    ),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        itemCount: _stories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 1.0,
          mainAxisSpacing: 1.0,
          mainAxisExtent: 250.0,
        ),
        itemBuilder: (context, index) {
          if (_stories[index].mediaType == MediaTypeEnum.image.name) {
            return GestureDetector(
              onTap: () => _selectStory(_idStories[index]),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                            _stories[index].mediaURL),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (_selectedStories.contains(_idStories[index]))
                    Container(
                      color: AppColors.backgroundColor.withOpacity(0.3),
                    ),
                  Positioned(
                    top: 10.0,
                    right: 10.0,
                    child: Stack(
                      children: [
                        Container(
                          width: 20.0,
                          height: 20.0,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.backgroundColor,
                              width: 2.0,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (_selectedStories.contains(_idStories[index]))
                          Container(
                            width: 20.0,
                            height: 20.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.backgroundColor,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: AppColors.infoColor,
                              size: 20.0,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return GestureDetector(
              onTap: () => _selectStory(_idStories[index]),
              child: Stack(
                children: [
                  ThumbnailStoryVideoComponent(
                      videoPath: _stories[index].mediaURL),
                  if (_selectedStories.contains(_idStories[index]))
                    Container(
                      color: AppColors.backgroundColor.withOpacity(0.3),
                    ),
                  Positioned(
                    top: 10.0,
                    right: 10.0,
                    child: Stack(
                      children: [
                        Container(
                          width: 20.0,
                          height: 20.0,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.backgroundColor,
                              width: 2.0,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (_selectedStories.contains(_idStories[index]))
                          Container(
                            width: 20.0,
                            height: 20.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.backgroundColor,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: AppColors.infoColor,
                              size: 20.0,
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
