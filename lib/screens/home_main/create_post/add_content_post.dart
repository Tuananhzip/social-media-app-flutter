import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:social_media_app/screens/home_main/home_main.dart';
import 'package:social_media_app/services/notifications/local_notifications_plugin.services.dart';
import 'package:social_media_app/services/posts/post.services.dart';
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

  @override
  initState() {
    super.initState();
    Logger().i(widget.fileList.map((e) => e.lengthSync()));
  }

  Future<void> _addPost() async {
    final String postText = _contentController.text;
    if (postText.isNotEmpty || widget.fileList.isNotEmpty) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeMain()),
          (Route<dynamic> route) => false);
      DialogNotifications.notificationInfo(
        // ignore: use_build_context_synchronously
        context,
        'Post uploading',
        'New post processing upload.',
      );
      await _postService
          .addPostToFirestore(postText, widget.fileList)
          .whenComplete(() => LocalNotificationServices().showLocalNotification(
              title: 'New post added',
              body: 'Your new post added successfully'));
    } else {
      DialogNotifications.notificationInfo(context, "Can't share new post",
          "Please enter the post content or select least one media");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                  return widget.widgetList[index];
                },
                options: CarouselOptions(
                  height: 300.0,
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
                    maxLines: 8, //or null
                    decoration: const InputDecoration.collapsed(
                        hintText: "What are you thinking?"),
                  ),
                ),
              ),
            ),
            Padding(
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
