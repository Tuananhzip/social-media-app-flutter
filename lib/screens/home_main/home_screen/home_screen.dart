import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_app/components/loading/overlay_loading.component.dart';
import 'package:social_media_app/components/post/post_srceen.component.dart';
import 'package:social_media_app/components/post/shimmer_post.component.dart';
import 'package:social_media_app/models/posts.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/screens/home_main/home_screen/notifications_screen/notifications_screen.dart';
import 'package:social_media_app/services/posts/post.services.dart';
import 'package:social_media_app/services/users/user.services.dart';
import 'package:social_media_app/theme/theme_provider.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final PostService _postService = PostService();
  final UserServices _userServices = UserServices();
  final List<Users?> _users = [];
  final List<Posts> _posts = [];
  bool _isLoadingDarkMode = false;
  bool _isLoadingData = false;
  late DocumentSnapshot? _lastVisible;
  final List<List<Widget>> _listOfListUrlPosts = [];
  bool isVolume = false;

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
        _loadPosts(lastVisible: _lastVisible).then((_) {
          _isLoadingData = false;
        });
      }
    }
  }

  Future<void> _loadPosts({DocumentSnapshot? lastVisible}) async {
    List<DocumentSnapshot> postData =
        await _postService.loadPostsLazy(lastVisible: lastVisible);
    if (postData.isNotEmpty) {
      _lastVisible = postData[postData.length - 1];
      List<Posts> postDummy = postData
          .map((data) => Posts.fromMap(data.data() as Map<String, dynamic>))
          .toList();
      postDummy.shuffle(); // Random shuffle list 10 posts orderBy created dated
      List<Future<Users?>> futures = postDummy
          .map((post) => _userServices.getUserDetailsByID(post.uid!))
          .toList();
      List<Users?> users = await Future.wait(futures);

      setState(() {
        if (lastVisible == null) {
          _posts.clear();
          _listOfListUrlPosts.clear();
          _users.clear();
        }
        _posts.addAll(postDummy);
        _users.addAll(users);
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

  String dateFormatPost(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return timeago.format(dateTime);
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
                final Users user = _users[index]!;
                return PostComponent(
                  imageUrlProfile: user.imageProfile,
                  username: '${user.username} + $index',
                  createDatePost:
                      dateFormatPost(_posts[index].postCreatedDate!),
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
    final VideoPlayerController controller =
        VideoPlayerController.networkUrl(Uri.parse(url));
    return FutureBuilder(
      future: controller.initialize(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("ERROR PLAY VIDEO ---> ${snapshot.error}"),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          return VisibilityDetector(
            key: Key(url),
            onVisibilityChanged: (visibilityInfo) {
              var visiblePercentage = visibilityInfo.visibleFraction * 100;
              if (visiblePercentage > 50) {
                controller.setLooping(true);
                controller.setVolume(0.0);
                controller.play();
                // ignore: avoid_print
                print(
                    'Video is $visiblePercentage% visible ${controller.value.volume}');
              } else {
                controller.pause();
              }
            },
            child: Stack(
              children: [
                VideoPlayer(controller),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return CircleAvatar(
                        backgroundColor: AppColors.blackColor.withOpacity(0.4),
                        child: IconButton(
                          icon: Icon(
                            color: AppColors.backgroundColor,
                            isVolume
                                ? Icons.volume_up_outlined
                                : Icons.volume_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              isVolume = !isVolume;
                              controller.setVolume(isVolume ? 1.0 : 0.0);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return Stack(
            children: [
              Positioned.fill(
                child: Image.memory(
                  data,
                  fit: BoxFit.fill,
                ),
              ),
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
