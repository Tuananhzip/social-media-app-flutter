import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social_media_app/components/loading/loading_flickr.component.dart';
import 'package:social_media_app/components/loading/shimmer_comment.component.dart';
import 'package:social_media_app/components/post/home_post/post_image_screen.dart';
import 'package:social_media_app/components/post/home_post/post_srceen.component.dart';
import 'package:social_media_app/components/post/home_post/post_video_player_screen.dart';
import 'package:social_media_app/models/post_comments.dart';
import 'package:social_media_app/models/posts.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/screens/home_main/home_screen/list_like_post_screen.dart';
import 'package:social_media_app/services/notifications/notifications.services.dart';
import 'package:social_media_app/services/postComments/post_comment.services.dart';
import 'package:social_media_app/services/postLikes/post_like.service.dart';
import 'package:social_media_app/services/posts/post.services.dart';
import 'package:social_media_app/services/users/user.services.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/my_enum.dart';
import 'package:social_media_app/utils/navigate.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({
    super.key,
    required this.listPostId,
    required this.indexPost,
  });
  final List<String> listPostId;
  final int indexPost;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();
  final _currentUser = FirebaseAuth.instance.currentUser;
  final PostService _postService = PostService();
  final PostLikeServices _postLikeServices = PostLikeServices();
  final PostCommentServices _postCommentServices = PostCommentServices();
  final NotificationServices _notificationServices = NotificationServices();
  final UserServices _userServices = UserServices();

  final List<List<Widget>> _listMedia = [];
  final List<Posts> _posts = [];
  final List<String> _postIds = [];
  final List<int> _postLikes = [];
  final List<int> _postComments = [];
  final List<bool> _isLiked = [];
  Users? _user;

  @override
  void initState() {
    super.initState();
    _fetchListPost();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchListPost() async {
    final List<DocumentSnapshot> listDataPost =
        await _postService.getListPostByListId(widget.listPostId);
    if (listDataPost.isNotEmpty) {
      final List<Posts> postsDummy = listDataPost
          .map((post) => Posts.fromMap(post.data() as Map<String, dynamic>))
          .toList();

      final List<String> postIds = listDataPost.map((post) => post.id).toList();

      final List<Future> futures = [
        Future.wait(listDataPost
            .map((post) => _postLikeServices.getQuantityPostLikes(post.id))
            .toList()),
        Future.wait(listDataPost
            .map((post) => _postCommentServices.getQuantityComments(post.id))
            .toList()),
        Future.wait(listDataPost
            .map((post) => _postLikeServices.isUserLikedPost(post.id))
            .toList()),
      ];
      final List results = await Future.wait(futures);

      final List<int> postLikes = results[0];
      final List<int> postComments = results[1];
      final List<bool> isLiked = results[2];

      _posts.addAll(postsDummy);
      _postIds.addAll(postIds);
      _postLikes.addAll(postLikes);
      _postComments.addAll(postComments);
      _isLiked.addAll(isLiked);
      _user = await _userServices.getUserDetailsByID(_currentUser!.uid);

      _checkListMedia(postsDummy);
      _scrollToIndex();
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _scrollToIndex() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && widget.indexPost < _posts.length) {
        _scrollController.animateTo(
          widget.indexPost * 550.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _checkListMedia(List<Posts> listPost) async {
    if (listPost.isNotEmpty) {
      List<List<Widget>> newListOfListUrlPosts = [];
      for (var post in listPost) {
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
      _listMedia.addAll(newListOfListUrlPosts);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            _user?.username != null
                ? Text(
                    _user?.username ?? 'Unknown',
                    style: const TextStyle(
                        color: AppColors.greyColor, fontSize: 14),
                  )
                : const SizedBox.shrink(),
            Text(
              'Posts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
      body: _posts.isNotEmpty
          ? ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                return PostComponent(
                  username: _user?.username ?? 'Unknown',
                  imageUrlPosts: _listMedia[index],
                  imageUrlProfile: _user?.imageProfile,
                  contentPost: _posts[index].postText ?? '',
                  createDatePost: _dateFormat(
                    _posts[index].postCreatedDate!,
                    useTimeAgo: true,
                  ),
                  postLikes: _postLikes[index],
                  postComments: _postComments[index],
                  isLiked: _isLiked[index],
                  onLikeToggle: () => _onLikeToggle(index),
                  onCommentToggle: () => _showComments(
                    _postIds[index],
                    _posts[index].uid!,
                    index,
                    autofocus: true,
                  ),
                  onShareToggle: () => _onShareToggle(
                      _posts[index].mediaLink, _posts[index].postText),
                  onViewLikes: () => navigateToScreenAnimationRightToLeft(
                      context, ListLikesScreen(postId: _postIds[index])),
                  onViewComments: () => _showComments(
                    _postIds[index],
                    _posts[index].uid!,
                    index,
                  ),
                  onViewProfile: () {
                    Navigator.pop(context);
                  },
                  itemBuilderPopupMenu: (context) {
                    return [MenuPostEnum.delete.name, MenuPostEnum.edit.name]
                        .map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                  onSelectedPopupMenu: (value) {
                    _onSelectedPopupMenu(value, _postIds[index]);
                  },
                );
              },
            )
          : const LoadingFlickrComponent(),
    );
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
                              leading: CachedNetworkImage(
                                imageUrl: user?.imageProfile ??
                                    'https://theatrepugetsound.org/wp-content/uploads/2023/06/Single-Person-Icon.png',
                                imageBuilder: (context, imageProvider) {
                                  return CircleAvatar(
                                    backgroundImage: imageProvider,
                                  );
                                },
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

  void _onShareToggle(List<String>? listMediaLinks, String? textPost) async {
    String? mediaLinksString;
    if (listMediaLinks != null) {
      mediaLinksString = listMediaLinks.join('\n');
    }
    await Share.share('$textPost\n\n$mediaLinksString');
  }

  void _onSelectedPopupMenu(String valueSelected, String postId) {
    if (valueSelected == MenuPostEnum.delete.name) {
      Logger().f('Delete $postId');
      _deletePost(postId);
    } else if (valueSelected == MenuPostEnum.edit.name) {
      Logger().f('Edit $postId');
    }
  }

  void _deletePost(String postId) async {
    await _postService.deletePost(postId).then((_) => _fetchListPost());
  }
}
