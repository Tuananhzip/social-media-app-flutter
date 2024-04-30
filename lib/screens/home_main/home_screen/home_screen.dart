import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_app/components/loading/overlay_loading.component.dart';
import 'package:social_media_app/components/post/post_srceen.component.dart';
import 'package:social_media_app/components/loading/shimmer_post.component.dart';
import 'package:social_media_app/models/post_comments.dart';
import 'package:social_media_app/models/posts.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/screens/home_main/create_post/create_post_screen.dart';
import 'package:social_media_app/screens/home_main/home_screen/list_like_post_screen.dart';
import 'package:social_media_app/screens/home_main/home_screen/notifications_screen/notifications_screen.dart';
import 'package:social_media_app/services/postComments/post_comment.services.dart';
import 'package:social_media_app/services/postLikes/post_like.service.dart';
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
  final Logger logger = Logger();
  final ScrollController _scrollController = ScrollController();
  final PostService _postService = PostService();
  final UserServices _userServices = UserServices();
  final PostLikeServices _postLikeServices = PostLikeServices();
  final PostCommentServices _postCommentServices = PostCommentServices();
  final TextEditingController _commentController = TextEditingController();
  final List<Users?> _users = [];
  final List<Posts> _posts = [];
  final List<String> _postIds = [];
  final List<int> _postLikes = [];
  final List<bool> _isLiked = [];
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
    _commentController.dispose();
  }

  void _scrollListen() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
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
      postData.shuffle(); // Random shuffle list 10 posts orderBy created dated
      List<Posts> postDummy = postData
          .map((data) => Posts.fromMap(data.data() as Map<String, dynamic>))
          .toList();
      List<String> postIds = postData.map((post) => post.id).toList();
      List<Future<Users?>> userFutures = postDummy
          .map((post) => _userServices.getUserDetailsByID(post.uid!))
          .toList();
      List<Future<int>> postLikeFutures = postData
          .map((post) => _postLikeServices.getQuantityPostLikes(post.id))
          .toList();
      List<Future<bool>> isLikedFutures = postData
          .map((post) => _postLikeServices.isUserLikedPost(post.id))
          .toList();
      List<Users?> users = await Future.wait(userFutures);
      List<int> postLikes = await Future.wait(postLikeFutures);
      List<bool> isLiked = await Future.wait(isLikedFutures);

      logger.i('postIds: $postIds ${postIds.length}');
      logger.i('postLikes: $postLikes ${postLikes.length}');
      logger.i('isLiked: $isLiked ${isLiked.length}');

      setState(() {
        if (lastVisible == null) {
          _listOfListUrlPosts.clear();
          _posts.clear();
          _users.clear();
          _postLikes.clear();
          _isLiked.clear();
          _postIds.clear();
        }
        _postLikes.addAll(postLikes);
        _posts.addAll(postDummy);
        _users.addAll(users);
        _isLiked.addAll(isLiked);
        _postIds.addAll(postIds);
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

  void onLikeToggle(int index) async {
    setState(() {
      _isLiked[index] = !_isLiked[index];
      if (_isLiked[index]) {
        _postLikes[index]++;
        _postLikeServices.likePost(_postIds[index]);
      } else {
        _postLikes[index]--;
        _postLikeServices.unlikePost(_postIds[index]);
      }
    });
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

  String _dateFormatPost(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return timeago.format(dateTime);
  }

  void _navigateToLikesScreen(String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListLikesScreen(postId: postId),
      ),
    );
  }

  void _showComments(String postId) {
    Future<void> addComment(String postId) async {
      final comment = _commentController.text;
      await _postCommentServices.addPostComment(postId, comment).then((value) {
        _commentController.clear();
      });
    }

    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              const Center(
                child: SizedBox(
                  width: 80.0,
                  height: 24.0,
                  child: Divider(
                    color: AppColors.grayAccentColor,
                    thickness: 5.0,
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Comments',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Divider(
                  color: AppColors.greyColor,
                  height: 1.0,
                ),
              ),
              Expanded(
                child: StreamBuilder<List<PostComments>>(
                  stream: _postCommentServices.getPostComments(postId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                            'Error loading comments ---> ${snapshot.error}'),
                      );
                    }
                    final List<PostComments> comment = snapshot.data!;
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: comment.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(comment[index].uid),
                          subtitle: Text(comment[index].commentText),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Theme.of(context).colorScheme.primary,
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.background,
                      hintText: 'Add a comment...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () => addComment(postId),
                        icon: const Icon(Icons.send),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const CreatePostScreen(), // replace with your actual CreatePostScreen
                      ),
                    );
                  },
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
              if (index < _posts.length &&
                  index < _listOfListUrlPosts.length &&
                  _users[index] != null) {
                final Users user = _users[index] ?? Users();
                return PostComponent(
                  imageUrlProfile: user.imageProfile,
                  username: '${user.username} + $index',
                  createDatePost:
                      _dateFormatPost(_posts[index].postCreatedDate!),
                  contentPost: _posts[index].postText ?? '',
                  imageUrlPosts: _listOfListUrlPosts[index],
                  postLikes: _postLikes[index],
                  onLikeToggle: () => onLikeToggle(index),
                  isLiked: _isLiked[index],
                  onViewLikes: () => _navigateToLikesScreen(_postIds[index]),
                  onViewComments: () => _showComments(_postIds[index]),
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
    final VideoPlayerController videoController =
        VideoPlayerController.networkUrl(Uri.parse(url));
    return FutureBuilder(
      future: videoController.initialize(),
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
                videoController.setLooping(true);
                videoController.setVolume(0.0);
                videoController.play();
                // ignore: avoid_print
                print(
                    'Video is $visiblePercentage% visible ${videoController.value.volume}');
              } else {
                videoController.pause();
              }
            },
            child: Stack(
              children: [
                VideoPlayer(videoController),
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
                              videoController.setVolume(isVolume ? 1.0 : 0.0);
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
