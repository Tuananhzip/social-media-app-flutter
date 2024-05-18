import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media_app/components/loading/overlay_loading.component.dart';
import 'package:social_media_app/components/loading/shimmer_post.component.dart';
import 'package:social_media_app/components/post/post_srceen.component.dart';
import 'package:social_media_app/models/posts.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/services/posts/post.services.dart';
import 'package:social_media_app/services/users/user.services.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
  final _currentUser = FirebaseAuth.instance.currentUser;
  final PostService _postService = PostService();
  final UserServices _userServices = UserServices();
  final List<List<Widget>> _listMedia = [];
  List<Posts> _listPost = [];
  Users? _user = Users();
  bool _isVolume = false;

  @override
  void initState() {
    super.initState();
    _fetchListPost();
    _fetchUser();
  }

  void _fetchListPost() async {
    final listDataPost =
        await _postService.getListPostByListId(widget.listPostId);
    _listPost = listDataPost
        .map((post) => Posts.fromMap(post.data() as Map<String, dynamic>))
        .toList();
    _checkListMedia(_listPost);
    _scrollToIndex();
  }

  void _fetchUser() async {
    _user = await _userServices.getUserDetailsByID(_currentUser!.uid);
  }

  void _scrollToIndex() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && widget.indexPost < _listPost.length) {
        _scrollController.animateTo(
          widget.indexPost * 550.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  String _dateFormatPost(Timestamp timestamp) {
    final DateFormat dateFormat = DateFormat('dd-MM-yyyy HH:mm');
    final String dateTime = dateFormat.format(timestamp.toDate());
    return dateTime;
  }

  void _checkListMedia(List<Posts> listPost) {
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
              listDummy.add(_buildImage(url));
            } else if (extendsions == 'mp4') {
              listDummy.add(_buildVideo(url));
            }
          }
        }
        newListOfListUrlPosts.add(listDummy);
      }
      setState(() {
        _listMedia.addAll(newListOfListUrlPosts);
      });
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
      body: _listPost.isNotEmpty
          ? ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              itemCount: _listPost.length,
              itemBuilder: (context, index) {
                return PostComponent(
                  username: _user?.username ?? 'Unknown',
                  imageUrlPosts: _listMedia[index],
                  imageUrlProfile: _user?.imageProfile,
                  contentPost: _listPost[index].postText ?? '',
                  createDatePost:
                      _dateFormatPost(_listPost[index].postCreatedDate!),
                  postLikes: 0,
                  postComments: 0,
                  isLiked: false,
                  onLikeToggle: () {},
                  onCommentToggle: () {},
                  onShareToggle: () {},
                  onViewLikes: () {},
                  onViewComments: () {},
                  onViewProfile: () {},
                );
              },
            )
          : const ShimmerPostComponent(),
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
  Widget _buildVideo(
    String url,
  ) {
    final VideoPlayerController videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(url));
    return FutureBuilder(
      future: videoPlayerController.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return VisibilityDetector(
            key: Key(url),
            onVisibilityChanged: (visibilityInfo) {
              var visiblePercentage = visibilityInfo.visibleFraction * 100;
              if (visiblePercentage > 50) {
                videoPlayerController.setLooping(true);
                videoPlayerController.setVolume(_isVolume ? 1.0 : 0.0);
                videoPlayerController.play();
              } else {
                videoPlayerController.pause();
              }
            },
            child: Stack(
              children: [
                VideoPlayer(videoPlayerController),
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
                            _isVolume
                                ? Icons.volume_up_outlined
                                : Icons.volume_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _isVolume = !_isVolume;
                              videoPlayerController
                                  .setVolume(_isVolume ? 1.0 : 0.0);
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
          return Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.primary,
              highlightColor: Theme.of(context).colorScheme.secondary,
              child: Container(
                color: Theme.of(context).colorScheme.background,
                height: 400.0,
                width: MediaQuery.of(context).size.width,
              ));
        }
      },
    );
  }
}
