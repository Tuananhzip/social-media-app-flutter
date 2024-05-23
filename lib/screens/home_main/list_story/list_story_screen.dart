import 'package:flutter/material.dart';
import 'package:social_media_app/components/story/story_image_screen.component.dart';
import 'package:social_media_app/models/stories.dart';
import 'package:social_media_app/services/stories/story.service.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/my_enum.dart';

class ListStoryScreen extends StatefulWidget {
  const ListStoryScreen({super.key});

  @override
  State<ListStoryScreen> createState() => _ListStoryScreenState();
}

class _ListStoryScreenState extends State<ListStoryScreen> {
  final StoryServices _storyServices = StoryServices();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          FutureBuilder(
            future: _storyServices.getAllStory(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Error'),
                );
              }
              final listStory = snapshot.data
                  ?.map(
                      (e) => Stories.fromMap(e.data() as Map<String, dynamic>))
                  .toList();
              final listId = snapshot.data?.map((e) => e.id).toList();
              return PageView.builder(
                itemCount: listStory?.length,
                itemBuilder: (context, index) {
                  if (listStory?[index].mediaType == MediaTypeEnum.image.name) {
                    return StoryImageComponentScreen(
                      storyId: listId![index],
                    );
                  } else {
                    return Container(
                      color: Colors.black,
                      child: Center(
                        child: Text(
                          'Video',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 42.0),
              child: Text(
                'Stories',
                style: TextStyle(
                  color: AppColors.backgroundColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
