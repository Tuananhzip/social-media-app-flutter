import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:social_media_app/components/loading/loading_flickr.dart';
import 'package:social_media_app/components/post/create_post_image_screen.component.dart';
import 'package:social_media_app/components/post/create_post_video_screen.component.dart';
import 'package:social_media_app/screens/home_main/create_post/add_content_post.dart';
import 'package:social_media_app/screens/home_main/create_post/create_story/create_story_screen.dart';
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
  final ImageServices _imageServices = ImageServices();
  final List<File> _fileList = [];
  final List<Widget> _widgetList = [];
  final List<VideoPlayerController> _videoControllers = [];
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    for (var controller in _videoControllers) {
      controller.dispose();
    }
  }

  Future<void> _getMedia() async {
    try {
      final pickedfileList = await _imageServices.pickMedia();
      if (pickedfileList.isEmpty) return;
      setState(() {
        _fileList.clear();
        _widgetList.clear();
        _videoControllers.clear();
        _isLoading = true;
      });

      final List<Future<void>> futures = [];

      for (var pickedMedia in pickedfileList) {
        if (pickedMedia == null) continue;

        if (pickedMedia.path.toLowerCase().endsWith('.mp4')) {
          setState(() {
            _fileList.add(pickedMedia);
            _widgetList.add(CreatePostVideoScreenComponent(file: pickedMedia));
          });
        } else {
          futures.add(_compressImage(pickedMedia));
        }
      }

      await Future.wait(futures).then((_) => setState(() {
            _isLoading = false;
          }));
      Logger().f(_widgetList.length);
      Logger().i(pickedfileList.length);
    } catch (error) {
      // ignore: avoid_print
      print("ERROR getMedia ---> $error");
      Logger().e(error);
    }
  }

  Future<void> _compressImage(File pickedMedia) async {
    final compressImage = await _imageServices.compressImage(pickedMedia);
    setState(() {
      _fileList.add(compressImage!);
      _widgetList.add(CreatePostImageScreenComponent(file: pickedMedia));
    });
  }

  Future<void> _getImageOrVideoWithCamera(MediaTypeEnum type) async {
    try {
      final pickedMedia = await _imageServices.pickWithCamera(type);

      if (pickedMedia == null) return;
      setState(() {
        _fileList.clear();
        _widgetList.clear();
        _videoControllers.clear();
        _isLoading = true;
      });

      if (pickedMedia.path.toLowerCase().endsWith('.mp4')) {
        setState(() {
          _fileList.add(pickedMedia);
          _widgetList.add(CreatePostVideoScreenComponent(file: pickedMedia));
        });
      } else {
        await _compressImage(pickedMedia);
      }
    } catch (error) {
      //ignore:avoid_print
      print("ERROR getImageOrVideoWithCamera ---> $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToAddContentPost() {
    if (!_isLoading) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddContentPost(
            fileList: _fileList,
            widgetList: _widgetList,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please wait, data is still loading')));
    }
  }

  void _navigateToMediaDetails(File file) {
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
              onPressed: _navigateToAddContentPost,
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
          if (_widgetList.isNotEmpty)
            CarouselSlider.builder(
              itemCount: _widgetList.length,
              itemBuilder: (context, index, realIndex) {
                return GestureDetector(
                  onTap: () => _navigateToMediaDetails(_fileList[index]),
                  child: _widgetList[index],
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
          if (_widgetList.isEmpty)
            GestureDetector(
              onTap: _getMedia,
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
                  child: _isLoading
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LoadingFlickrComponent(),
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
          if (_widgetList.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: _navigateToAddContentPost,
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
                    onPressed: _getMedia,
                    icon: const Icon(Icons.photo_library_outlined),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: IconButton(
                    iconSize: 32,
                    onPressed: () =>
                        _getImageOrVideoWithCamera(MediaTypeEnum.image),
                    icon: const Icon(Icons.camera_alt_outlined),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: IconButton(
                    iconSize: 32,
                    onPressed: () =>
                        _getImageOrVideoWithCamera(MediaTypeEnum.video),
                    icon: const Icon(Icons.video_call_outlined),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: null,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.blue.withOpacity(0.7),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        side: BorderSide(
                            width: 1.0,
                            color: Theme.of(context).colorScheme.secondary),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          bottomLeft: Radius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                  child: const Text('Post'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const CreateStoryScreen())),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        side: BorderSide(
                            width: 1.0,
                            color: Theme.of(context).colorScheme.secondary),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                  child: const Text('Story'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
