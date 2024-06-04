import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_app/components/loading/shimmer_comment.component.dart';
import 'package:social_media_app/components/loading/shimmer_post.component.dart';
import 'package:social_media_app/components/post/home_post/post_image_screen.dart';
import 'package:social_media_app/components/post/home_post/post_srceen.component.dart';
import 'package:social_media_app/components/post/home_post/post_video_player_screen.dart';
import 'package:social_media_app/models/post_comments.dart';
import 'package:social_media_app/models/posts.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/screens/home_main/home_screen/list_like_post_screen.dart';
import 'package:social_media_app/screens/home_main/home_screen/notifications_screen/notifications_screen.dart';
import 'package:social_media_app/screens/home_main/search/profile_users_screen.dart';
import 'package:social_media_app/services/notifications/notifications.services.dart';
import 'package:social_media_app/services/postComments/post_comment.services.dart';
import 'package:social_media_app/services/postLikes/post_like.service.dart';
import 'package:social_media_app/services/posts/post.services.dart';
import 'package:social_media_app/services/users/user.services.dart';
import 'package:social_media_app/theme/theme_provider.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/my_enum.dart';
import 'package:social_media_app/utils/navigate.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _currentUser = FirebaseAuth.instance.currentUser;
  final Logger _logger = Logger();
  final ScrollController _listScrollController = ScrollController();
  final PostService _postService = PostService();
  final UserServices _userServices = UserServices();
  final PostLikeServices _postLikeServices = PostLikeServices();
  final PostCommentServices _postCommentServices = PostCommentServices();
  final NotificationServices _notificationServices = NotificationServices();
  final TextEditingController _commentController = TextEditingController();
  final List<Users?> _users = [];
  final List<Posts> _posts = [];
  final List<String> _postIds = [];
  final List<int> _postLikes = [];
  final List<int> _postComments = [];
  final List<bool> _isLiked = [];
  bool _isLoadingDarkMode = false;
  bool _isLoadingData = false;
  bool _isDataLoaded = false;
  late DocumentSnapshot? _lastVisible;
  final List<List<Widget>> _listOfListUrlPosts = [];

  @override
  initState() {
    super.initState();
    _initDarkMode();
    _loadPosts();
    _listScrollController.addListener(_scrollListen);
  }

  @override
  void dispose() {
    _listScrollController.removeListener(_scrollListen);
    _listScrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _showComments(String postId, String uidOfPost, int indexOfCountComment,
      {bool autofocus = false}) {
    Future<void> addComment() async {
      final comment = _commentController.text;
      await _postCommentServices.addPostComment(postId, comment).then((value) {
        _commentController.clear();
        setState(() {
          _postComments[indexOfCountComment]++;
        });
        FocusManager.instance.primaryFocus?.unfocus();
      });
      if (_currentUser!.uid != uidOfPost) {
        final usernameCommented = await _userServices
            .getUserDetailsByID(_currentUser.uid)
            .then((value) => value?.username);
        await _notificationServices.sendNotificationTypeComment(
          usernameCommented!,
          uidOfPost,
        );
      }
    }

    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
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
                  builder: (context, commentsSnapshot) {
                    if (commentsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return LoadingAnimationWidget.flickr(
                        leftDotColor: AppColors.loadingLeftBlue,
                        rightDotColor: AppColors.loadingRightRed,
                        size: 30.0,
                      );
                    } else if (commentsSnapshot.hasError) {
                      return Center(
                        child: Text(
                            'Error loading comments ---> ${commentsSnapshot.error}'),
                      );
                    } else if (commentsSnapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                            'You will be the first to comment on this post'),
                      );
                    }
                    final List<PostComments> comment = commentsSnapshot.data!;
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: comment.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<Users?>(
                          future: _userServices
                              .getUserDetailsByID(comment[index].uid),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const ShimmerCommentComponent();
                            } else if (userSnapshot.hasError) {
                              return Center(
                                child: Text(
                                    'Error loading comments ---> ${userSnapshot.error}'),
                              );
                            }
                            final Users? user = userSnapshot.data;
                            return ListTile(
                              leading: SizedBox(
                                height: 40.0,
                                width: 40.0,
                                child: CachedNetworkImage(
                                  imageUrl: user?.imageProfile ??
                                      'https://theatrepugetsound.org/wp-content/uploads/2023/06/Single-Person-Icon.png',
                                  imageBuilder: (context, imageProvider) {
                                    return CircleAvatar(
                                      backgroundImage: imageProvider,
                                    );
                                  },
                                ),
                              ),
                              title: Text(user?.username ?? 'Unknown'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment[index].commentText,
                                    style:
                                        Theme.of(context).textTheme.labelLarge,
                                  ),
                                  Text(
                                    _dateFormat(
                                        comment[index].commentCreatedTime),
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Theme.of(context).colorScheme.primary,
                child: TextField(
                  autofocus: autofocus,
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
                    suffixIcon: ValueListenableBuilder(
                      valueListenable: _commentController,
                      builder: (context, value, child) {
                        return value.text.trim().isNotEmpty
                            ? IconButton(
                                onPressed: addComment,
                                icon: const Icon(Icons.send),
                              )
                            : const SizedBox.shrink();
                      },
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
      appBar: AppBar(
        title: const Text(
          "Minthwhite",
          style: TextStyle(
            fontFamily: "Italianno",
            fontSize: 36.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Switch(
              value: _isLoadingDarkMode,
              onChanged: (value) => _toggleChangeTheme(context),
              inactiveThumbImage: const AssetImage('assets/images/sun.png'),
              activeThumbImage: const AssetImage('assets/images/moon.png'),
              inactiveThumbColor: AppColors.backgroundColor,
              activeColor: AppColors.grayAccentColor,
              inactiveTrackColor: AppColors.blueColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                IconButton(
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const NotificationsScreen(),
                    //   ),
                    // );
                    navigateToScreenAnimationRightToLeft(
                        context, const NotificationsScreen());
                  },
                  icon: const Icon(Icons.notifications_none_outlined),
                ),
                StreamBuilder<bool>(
                  stream: _notificationServices.checkNotifications(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                            'Error loading notifications ---> ${snapshot.error}'),
                      );
                    }
                    if (snapshot.data == true) {
                      return Positioned(
                        right: 15,
                        top: 12,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.dangerColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        child: Stack(
          children: [
            _posts.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.zero,
                    controller: _listScrollController,
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final Users user = _users[index] ?? Users();
                      return PostComponent(
                        imageUrlProfile: user.imageProfile,
                        username: "${user.username} [$index]",
                        createDatePost: _dateFormat(
                          _posts[index].postCreatedDate!,
                          useTimeAgo: true,
                        ),
                        contentPost: _posts[index].postText ?? '',
                        imageUrlPosts: _listOfListUrlPosts[index],
                        postLikes: _postLikes[index],
                        postComments: _postComments[index],
                        onLikeToggle: () => _onLikeToggle(index),
                        onCommentToggle: () => _showComments(
                          _postIds[index],
                          _posts[index].uid!,
                          index,
                          autofocus: true,
                        ),
                        onShareToggle: () => _onShareToggle(
                            _posts[index].mediaLink, _posts[index].postText),
                        isLiked: _isLiked[index],
                        onViewLikes: () =>
                            _navigateToLikesScreen(_postIds[index]),
                        onViewComments: () => _showComments(
                          _postIds[index],
                          _posts[index].uid!,
                          index,
                        ),
                        onViewProfile: () =>
                            _navigateToProfileScreen(_posts[index].uid!),
                        itemBuilderPopupMenu: (context) {
                          if (_posts[index].uid == _currentUser!.uid) {
                            return [
                              MenuPostEnum.delete.name,
                              MenuPostEnum.edit.name
                            ].map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice),
                              );
                            }).toList();
                          } else {
                            return [
                              MenuPostEnum.report.name,
                            ].map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice),
                              );
                            }).toList();
                          }
                        },
                        onSelectedPopupMenu: (value) {
                          _onSelectedPopupMenu(value, _postIds[index]);
                        },
                      );
                    },
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return const ShimmerPostComponent();
                    },
                  ),
            !_isDataLoaded && _posts.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: LoadingAnimationWidget.flickr(
                        leftDotColor: AppColors.loadingLeftBlue,
                        rightDotColor: AppColors.loadingRightRed,
                        size: 30.0,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  void _scrollListen() {
    if (_listScrollController.position.pixels ==
        _listScrollController.position.maxScrollExtent) {
      Logger().d("Reached bottom");
      if (!_isLoadingData) {
        _isLoadingData = true;
        _loadPosts(lastVisible: _lastVisible)
            .then((value) => _isLoadingData = false);
      }
    }
  }

  Future<void> _loadPosts({DocumentSnapshot? lastVisible}) async {
    if (lastVisible == null) {
      _logger.t(lastVisible);
      _clearPost();
    }
    List<DocumentSnapshot> postData =
        await _postService.loadPostsLazy(lastVisible: lastVisible);
    if (postData.isNotEmpty) {
      setState(() {
        _isDataLoaded = false;
      });
      _lastVisible = postData.last;

      postData.shuffle(); // Random shuffle list 10 posts orderBy created dated

      final List<Posts> postDummy = postData
          .map((data) => Posts.fromMap(data.data() as Map<String, dynamic>))
          .toList();

      final List<String> postIds = postData.map((post) => post.id).toList();

      final List<Future> futures = [
        Future.wait(postDummy
            .map((post) => _userServices.getUserDetailsByID(post.uid!))
            .toList()),
        Future.wait(postData
            .map((post) => _postLikeServices.getQuantityPostLikes(post.id))
            .toList()),
        Future.wait(postData
            .map((post) => _postCommentServices.getQuantityComments(post.id))
            .toList()),
        Future.wait(postData
            .map((post) => _postLikeServices.isUserLikedPost(post.id))
            .toList()),
      ];

      final List results = await Future.wait(futures);

      final List<Users?> users = results[0];
      final List<int> postLikes = results[1];
      final List<int> postComments = results[2];
      final List<bool> isLiked = results[3];

      _logger.i('postIds: $postIds ${postIds.length}');
      _logger.i('postLikes: $postLikes ${postLikes.length}');
      _logger.i('postComments: $postComments ${postComments.length}');
      _logger.i('isLiked: $isLiked ${isLiked.length}');

      _posts.addAll(postDummy);
      _postIds.addAll(postIds);
      _postLikes.addAll(postLikes);
      _postComments.addAll(postComments);
      _users.addAll(users);
      _isLiked.addAll(isLiked);

      _checkMediaList(postDummy);
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  void _checkMediaList(List<Posts> postsDummy) {
    if (postsDummy.isNotEmpty) {
      List<List<Widget>> newListOfListUrlPosts = [];
      for (var post in postsDummy) {
        List<Widget> listDummy = [];
        if (post.mediaLink != null || post.mediaLink!.isNotEmpty) {
          for (var url in post.mediaLink!) {
            final listPart = url.split('.');
            final lastPart = listPart.last.toLowerCase().split('?');
            final String extendsions = lastPart.first;
            if (extendsions == 'jpg' ||
                extendsions == 'png' ||
                extendsions == 'jpeg') {
              listDummy.add(PostImageScreenComponent(
                url: url,
              ));
            } else if (extendsions == 'mp4') {
              listDummy.add(PostVideoPlayerScreenComponent(
                url: url,
              ));
            }
          }
        }
        newListOfListUrlPosts.add(listDummy);
      }
      _listOfListUrlPosts.addAll(newListOfListUrlPosts);
    }
  }

  void _clearPost() {
    _listOfListUrlPosts.clear();
    _posts.clear();
    _users.clear();
    _postLikes.clear();
    _isLiked.clear();
    _postIds.clear();
    _postComments.clear();
  }

  void _onLikeToggle(int index) async {
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

  void _onShareToggle(List<String>? listMediaLinks, String? textPost) async {
    String? mediaLinksString;
    if (listMediaLinks != null) {
      mediaLinksString = listMediaLinks.join('\n');
    }
    await Share.share('$textPost\n\n$mediaLinksString');
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

  String _dateFormat(Timestamp timestamp, {bool useTimeAgo = false}) {
    final DateTime dateTime = timestamp.toDate();
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);

    if (useTimeAgo && difference.inDays <= 7) {
      return timeago.format(dateTime);
    } else {
      if (dateTime.year == now.year) {
        return DateFormat('MMMM dd,').add_jm().format(dateTime);
      } else {
        return DateFormat.yMMMMEEEEd().format(dateTime);
      }
    }
  }

  void _navigateToLikesScreen(String postId) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ListLikesScreen(postId: postId),
    //   ),
    // );
    navigateToScreenAnimationRightToLeft(
        context, ListLikesScreen(postId: postId));
  }

  void _navigateToProfileScreen(String uid) async {
    final user = await _userServices.getUserDetailsByID(uid);
    // Navigator.push(
    //   // ignore: use_build_context_synchronously
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ProfileUsersScreen(
    //       user: user!,
    //       uid: uid,
    //     ),
    //   ),
    // );
    if (mounted) {
      navigateToScreenAnimationRightToLeft(
        context,
        ProfileUsersScreen(
          user: user!,
          uid: uid,
        ),
      );
    }
  }

  void _onSelectedPopupMenu(String valueSelected, String postId) {
    if (valueSelected == MenuPostEnum.delete.name) {
      // ignore: avoid_print
      print('Delete $postId');
      _deletePost(postId);
    } else if (valueSelected == MenuPostEnum.edit.name) {
      // ignore: avoid_print
      print('Edit $postId');
    }
  }

  void _deletePost(String postId) async {
    await _postService
        .deletePost(postId)
        .then((_) => _loadPosts(lastVisible: null));
  }
}
