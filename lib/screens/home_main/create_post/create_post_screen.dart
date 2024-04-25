import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/screens/home_main/create_post/add_content_post.dart';
import 'package:social_media_app/screens/home_main/create_post/media_details_screen.dart';
import 'package:social_media_app/services/images/images.services.dart';
import 'package:social_media_app/utils/my_enum.dart';
import 'package:video_player/video_player.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final ImageServices imageServices = ImageServices();
  List<File> fileList = [];
  List<Widget> widgetList = [];
  List<VideoPlayerController> videoControllers = [];
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    for (var controller in videoControllers) {
      controller.dispose();
    }
  }

  Future<void> getMedia() async {
    try {
      setState(() {
        fileList.clear();
        widgetList.clear();
        videoControllers.clear();
      });

      final pickedfileList = await imageServices.pickMedia();
      if (pickedfileList.isEmpty) return;

      setState(() {
        isLoading = true;
      });

      final List<Future<void>> futures = [];

      for (var pickedMedia in pickedfileList) {
        if (pickedMedia == null) continue;

        if (pickedMedia.path.toLowerCase().endsWith('.mp4')) {
          futures.add(initializeVideo(pickedMedia));
        } else {
          futures.add(compressImage(pickedMedia));
        }
      }

      await Future.wait(futures).whenComplete(() => setState(() {
            isLoading = false;
          }));
    } catch (error) {
      // ignore: avoid_print
      print("ERROR getMedia ---> $error");
    }
  }

  Future<void> initializeVideo(File pickedMedia) async {
    final controller = VideoPlayerController.file(pickedMedia);
    await controller.initialize();
    setState(() {
      fileList.add(pickedMedia); // add list file store firebase
      widgetList.add(buildVideo(controller)); // add widget video
      videoControllers
          .add(controller); // add controller of video maintain value option
    });
  }

  Future<void> compressImage(File pickedMedia) async {
    final compressImage = await imageServices.compressImage(pickedMedia);
    setState(() {
      fileList.add(compressImage!); // add list file store firebase
      widgetList.add(buildImage(compressImage)); // add widget image
    });
  }

  Future<void> getImageOrVideoWithCamera(MediaTypeEnum type) async {
    try {
      setState(() {
        fileList.clear();
        widgetList.clear();
        videoControllers.clear();
      });

      final pickedMedia = await imageServices.pickWithCamera(type);
      if (pickedMedia == null) return;

      setState(() {
        isLoading = true;
      });

      if (pickedMedia.path.toLowerCase().endsWith('.mp4')) {
        await initializeVideo(pickedMedia);
      } else {
        await compressImage(pickedMedia);
      }
    } catch (error) {
      //ignore:avoid_print
      print("ERROR getImageOrVideoWithCamera ---> $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToAddContentPost() {
    if (!isLoading) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddContentPost(
            fileList: fileList,
            widgetList: widgetList,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please wait, data is still loading')));
    }
  }

  void navigateToMediaDetails(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaDetailScreen(file: file),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Create Post"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 0,
            ),
            child: TextButton(
              onPressed: navigateToAddContentPost,
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
          const SizedBox(
            height: 16.0,
          ),
          if (widgetList.isNotEmpty)
            CarouselSlider.builder(
              itemCount: widgetList.length,
              itemBuilder: (context, index, realIndex) {
                return InkWell(
                  onTap: () => navigateToMediaDetails(fileList[index]),
                  child: widgetList[index],
                );
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
          if (widgetList.isEmpty)
            GestureDetector(
              onTap: getMedia,
              child: Container(
                width: 400.0,
                height: 500.0,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                margin: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(width: 1.0),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Center(
                  child: isLoading
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            Text('Loading...')
                          ],
                        )
                      : const Icon(
                          Icons.image_outlined,
                          size: 50,
                        ),
                ),
              ),
            ),
          if (widgetList.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: navigateToAddContentPost,
                child: const Text(
                  'You can skip the image/video and click "Next"',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: IconButton(
                    iconSize: 32,
                    onPressed: getMedia,
                    icon: const Icon(Icons.photo_library_outlined),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: IconButton(
                    iconSize: 32,
                    onPressed: () =>
                        getImageOrVideoWithCamera(MediaTypeEnum.image),
                    icon: const Icon(Icons.camera_alt_outlined),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: IconButton(
                    iconSize: 32,
                    onPressed: () =>
                        getImageOrVideoWithCamera(MediaTypeEnum.video),
                    icon: const Icon(Icons.video_call_outlined),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImage(File file) => Container(
        width: 400.0,
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(
            file,
            fit: BoxFit.cover,
          ),
        ),
      );
  Widget buildVideo(VideoPlayerController videoController) => Container(
        width: 400.0,
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: videoController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: videoController.value.aspectRatio,
                  child: VideoPlayer(videoController),
                )
              : const SizedBox(),
        ),
      );
}
