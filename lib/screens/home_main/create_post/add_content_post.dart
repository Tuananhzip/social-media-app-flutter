import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:social_media_app/components/loading/loading_flickr.component.dart';
import 'package:social_media_app/components/post/create_post/create_post_video_player_screen.component.dart';
import 'package:social_media_app/screens/home_main/home_main.dart';
import 'package:social_media_app/services/posts/post.services.dart';
import 'package:social_media_app/utils/my_enum.dart';
import 'package:social_media_app/utils/notifications_dialog.dart';

class AddContentPost extends StatefulWidget {
  const AddContentPost({
    super.key,
    required this.fileList,
    required this.widgetList,
  });
  final List<File> fileList;
  final List<Widget> widgetList;

  @override
  State<AddContentPost> createState() => _AddContentPostState();
}

class _AddContentPostState extends State<AddContentPost> {
  final PostService _postService = PostService();
  final TextEditingController _contentController = TextEditingController();
  bool _isUploading = false;

  @override
  initState() {
    super.initState();
    Logger().i(widget.fileList.map((e) => e.lengthSync()));
  }

  Future<void> _addPost() async {
    setState(() {
      _isUploading = true;
    });
    final String postText = _contentController.text;
    if (mounted) {
      if (postText.isNotEmpty || widget.fileList.isNotEmpty) {
        DialogNotifications.notificationInfo(
          context,
          'Post uploading',
          'New post processing upload.',
        );
        await _postService
            .addPostToFirestore(postText, widget.fileList)
            .then((_) => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const HomeMain(
                          fragment: Fragments.profileScreen,
                        )),
                (Route<dynamic> route) => false));
      } else {
        DialogNotifications.notificationInfo(context, "Can't share new post",
            "Please enter the post content or select least one media");
      }
    }
    if (mounted) {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _navigateToVideoPlayerScreen(File videoPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostVideoPlayerScreenComponent(
          videoPath: videoPath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !_isUploading,
        title: const Text('Add Content'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 16.0,
            ),
            if (widget.widgetList.isNotEmpty)
              CarouselSlider.builder(
                itemCount: widget.widgetList.length,
                itemBuilder: (context, index, realIndex) {
                  if (widget.fileList[index].path
                      .toLowerCase()
                      .endsWith('.mp4')) {
                    return GestureDetector(
                      onTap: () => _navigateToVideoPlayerScreen(
                        widget.fileList[index],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          widget.widgetList[index],
                          const Positioned.fill(
                            child: Icon(
                              Icons.play_arrow,
                              size: 50.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return widget.widgetList[index];
                  }
                },
                options: CarouselOptions(
                  height: 500.0,
                  viewportFraction: 1,
                  enlargeCenterPage: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.height,
                  enableInfiniteScroll: false,
                  scrollDirection: Axis.horizontal,
                ),
              ),
            if (widget.widgetList.isEmpty)
              Container(
                width: 400.0,
                height: 300.0,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                margin: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(width: 1.0),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  size: 50,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _contentController,
                    maxLines: 5, //or null
                    decoration: const InputDecoration.collapsed(
                        hintText: "What are you thinking?"),
                  ),
                ),
              ),
            ),
            _isUploading
                ? const LoadingFlickrComponent()
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: 50,
                      width: 400,
                      child: ElevatedButton(
                        onPressed: _addPost,
                        child: const Text(
                          'Share',
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
