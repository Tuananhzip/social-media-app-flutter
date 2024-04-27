import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_app/components/dialog/dialog_video_player.component.dart';
import 'package:social_media_app/components/loading/overlay_loading.component.dart';
import 'package:social_media_app/components/post/post_srceen.component.dart';
import 'package:social_media_app/components/post/shimmer_post.component.dart';
import 'package:social_media_app/models/posts.dart';
import 'package:social_media_app/screens/home_main/home_screen/notifications_screen/notifications_screen.dart';
import 'package:social_media_app/services/posts/post.services.dart';
import 'package:social_media_app/theme/theme_provider.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final PostService _postService = PostService();
  final List<Posts> _posts = [];
  bool _isLoadingDarkMode = false;
  bool _isLoadingData = false;
  late DocumentSnapshot? _lastVisible;
  final List<List<Widget>> _listOfListUrlPosts = [];

  @override
  initState() {
    super.initState();
    _initDarkMode();
    _loadPosts();
    _scrollController.addListener(_scrollListen);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_scrollListen);
    _scrollController.dispose();
  }

  void _scrollListen() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent * 0.9) {
      if (!_isLoadingData) {
        _isLoadingData = true;
        _loadMorePosts().then((_) {
          _isLoadingData = false;
        });
      }
    }
  }

  Future<void> _loadPosts() async {
    List<DocumentSnapshot> postData = await _postService.loadPostsLazy();
    if (postData.isNotEmpty) {
      _lastVisible = postData[postData.length - 1];
      List<Posts> postDummy = postData
          .map((data) => Posts.formMap(data.data() as Map<String, dynamic>))
          .toList();
      setState(() {
        _posts.clear();
        _listOfListUrlPosts.clear();
        _posts.addAll(postDummy);
      });
      _checkMediaList(_posts);
    }
  }

  Future<void> _loadMorePosts() async {
    List<DocumentSnapshot> morePosts =
        await _postService.loadPostsLazy(lastVisible: _lastVisible);
    if (morePosts.isNotEmpty) {
      _lastVisible = morePosts[morePosts.length - 1];
      List<Posts> postDummy = morePosts
          .map((data) => Posts.formMap(data.data() as Map<String, dynamic>))
          .toList();
      setState(() {
        _posts.addAll(postDummy);
      });
      _checkMediaList(postDummy);
    }
  }

  void _checkMediaList(List<Posts> postsDummy) async {
    if (postsDummy.isNotEmpty) {
      List<List<Widget>> newListOfListUrlPosts = [];
      for (var post in postsDummy) {
        List<Widget> listDummy = [];
        if (post.mediaLink != null || post.mediaLink!.isNotEmpty) {
          List<Future> futures = [];
          for (var url in post.mediaLink!) {
            final listPart = url.split('.');
            final lastPart = listPart.last.toLowerCase().split('?');
            String extensions = lastPart.first;
            if (extensions == 'jpg' ||
                extensions == 'png' ||
                extensions == 'jpeg') {
              listDummy.add(_buildImage(url));
            } else if (extensions == 'mp4') {
              futures.add(
                VideoThumbnail.thumbnailData(
                  video: url,
                  imageFormat: ImageFormat.JPEG,
                  maxWidth: MediaQuery.of(context).size.width.toInt(),
                  maxHeight: MediaQuery.of(context).size.height.toInt(),
                  quality: 25,
                ).then((uint8list) {
                  if (uint8list != null) {
                    listDummy.add(_buildVideo(uint8list, url));
                  }
                }).catchError((onError) {
                  // ignore: avoid_print
                  print('Failed to fetch video thumbnail: $onError');
                }),
              );
            }
          }
          // Wait for all futures to complete
          await Future.wait(futures);
        }
        newListOfListUrlPosts.add(listDummy);
      }
      setState(() {
        _listOfListUrlPosts.addAll(newListOfListUrlPosts);
      });
    }
  }

  Future<void> _initDarkMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoadingDarkMode = prefs.getBool("isDarkMode")!;
    });
  }

  Future<void> _toggleChangeTheme(context) async {
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoadingDarkMode = prefs.getBool("isDarkMode")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text(
                "Minthwhite",
                style: TextStyle(
                  fontFamily: "Italianno",
                  fontSize: 42.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                Switch(
                  value: _isLoadingDarkMode,
                  onChanged: (value) => _toggleChangeTheme(context),
                  inactiveThumbImage: const AssetImage('assets/images/sun.png'),
                  activeThumbImage: const AssetImage('assets/images/moon.png'),
                  inactiveThumbColor: AppColors.backgroundColor,
                  activeColor: AppColors.grayAccentColor,
                  inactiveTrackColor: AppColors.blueColor,
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add_box_outlined),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications_none_outlined),
                ),
              ],
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: _loadPosts,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.vertical,
            controller: _scrollController,
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              if (index < _posts.length && index < _listOfListUrlPosts.length) {
                return PostComponent(
                  username: '${_posts[index].uid!}-(${index + 1})',
                  createDatePost: _posts[index].postCreatedDate.toString(),
                  contentPost: _posts[index].postText ?? '',
                  imageUrlPosts: _listOfListUrlPosts[index],
                );
              } else {
                return const ShimmerPostComponent();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String url) => SizedBox(
        width: MediaQuery.of(context).size.width,
        child: CachedNetworkImage(
          imageUrl: url,
          imageBuilder: (context, imageProvider) {
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
          placeholder: (context, url) => const OverlayLoadingWidget(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      );
  Widget _buildVideo(Uint8List data, String url) {
    return GestureDetector(
      onTap: () {
        showVideoDialog(context, url);
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.memory(
              data,
              fit: BoxFit.fill,
            ),
          ),
          const Positioned.fill(
            child: Icon(
              Icons.play_circle_outline,
              color: Colors.white,
              size: 70.0,
            ),
          ),
        ],
      ),
    );
  }
}
