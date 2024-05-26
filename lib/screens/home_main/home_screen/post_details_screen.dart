import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/components/loading/loading_flickr.dart';
import 'package:social_media_app/components/loading/shimmer_post.component.dart';
import 'package:social_media_app/components/post/home_post/post_image_screen.dart';
import 'package:social_media_app/components/post/home_post/post_srceen.component.dart';
import 'package:social_media_app/components/post/home_post/post_video_player_screen.dart';
import 'package:social_media_app/models/posts.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/services/posts/post.services.dart';
import 'package:social_media_app/services/users/user.services.dart';
import 'package:social_media_app/utils/app_colors.dart';

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
  final List<Posts> _listPost = [];
  Users? _user = Users();
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchListPost();
    _fetchUser();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _fetchListPost() async {
    setState(() {
      _isDataLoaded = false;
    });
    final listDataPost =
        await _postService.getListPostByListId(widget.listPostId);
    final List<Posts> postsDummy = listDataPost
        .map((post) => Posts.fromMap(post.data() as Map<String, dynamic>))
        .toList();
    _listPost.addAll(postsDummy);
    _checkListMedia(postsDummy);
    setState(() {
      _isDataLoaded = true;
    });
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
      body: _isDataLoaded
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
          : const LoadingFlickrComponent(),
    );
  }
}
