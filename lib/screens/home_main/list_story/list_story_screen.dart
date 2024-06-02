import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/loading/loading_flickr.component.dart';
import 'package:social_media_app/components/story/story_image_screen.component.dart';
import 'package:social_media_app/components/story/story_video_screen.component.dart';
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
      backgroundColor: AppColors.blackColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          FutureBuilder(
            future: _storyServices.getAllStory(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error ---> ${snapshot.error}'),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingFlickrComponent();
              }

              final listStory = snapshot.data
                  ?.map(
                      (e) => Stories.fromMap(e.data() as Map<String, dynamic>))
                  .toList();
              final listId = snapshot.data?.map((e) => e.id).toList();
              return CarouselSlider.builder(
                itemCount: listStory?.length,
                itemBuilder: (context, index, realIndex) {
                  if (listStory?[index].mediaType == MediaTypeEnum.image.name) {
                    return StoryImageComponentScreen(
                      storyId: listId![index],
                    );
                  } else if (listStory?[index].mediaType ==
                      MediaTypeEnum.video.name) {
                    return StoryVideoComponentScreen(
                      storyId: listId![index],
                    );
                  } else {
                    return const Center(
                      child: Text('ERROR not is image or video type'),
                    );
                  }
                },
                options: CarouselOptions(
                  autoPlay: false,
                  height: MediaQuery.of(context).size.height,
                  viewportFraction: 1,
                  enlargeStrategy: CenterPageEnlargeStrategy.height,
                  enableInfiniteScroll: false,
                  scrollDirection: Axis.vertical,
                ),
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
