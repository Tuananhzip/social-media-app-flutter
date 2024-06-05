import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media_app/components/button/button_default.component.dart';
import 'package:social_media_app/components/loading/loading_flickr.component.dart';
import 'package:social_media_app/components/story/story_screen.component.dart';
import 'package:social_media_app/components/story/thumbnail_story_video.component.dart';
import 'package:social_media_app/components/view/photo_view_page.component.dart';
import 'package:social_media_app/models/featured_story.dart';
import 'package:social_media_app/models/posts.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/screens/home_main/profile/list_friend_screen.dart';
import 'package:social_media_app/screens/home_main/profile/post_details_screen.dart';
import 'package:social_media_app/screens/home_main/profile/update_profile_screen.dart';
import 'package:social_media_app/services/featuredStories/featured_story.service.dart';
import 'package:social_media_app/services/friendRequests/friend_request.services.dart';
import 'package:social_media_app/services/images/images.services.dart';
import 'package:social_media_app/services/posts/post.services.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/field_names.dart';
import 'package:social_media_app/utils/navigate.dart';

class ProfileUsersScreen extends StatefulWidget {
  const ProfileUsersScreen({
    super.key,
    required this.user,
    required this.uid,
  });
  final Users user;
  final String uid;

  @override
  State<ProfileUsersScreen> createState() => _ProfileUsersScreenState();
}

class _ProfileUsersScreenState extends State<ProfileUsersScreen> {
  final _currentUser = FirebaseAuth.instance.currentUser;
  final ImageServices _imageServices = ImageServices();
  final FriendRequestsServices _friendRequestsServices =
      FriendRequestsServices();
  final PostService _postService = PostService();
  final FeaturedStoryServices _featuredStoryServices = FeaturedStoryServices();
  late Future<List<DocumentSnapshot>> _futurePosts;
  final List<String> _listUidOfPosts = [];
  late Future<int> _futureFriends;

  List<FeaturedStory> _featuredStories = [];
  List<String> _featuredStoriesId = [];

  @override
  void initState() {
    super.initState();

    _futurePosts = _loadPosts();
    _futureFriends = _loadFriends();
    _loadFeaturedStories();
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UpdateProfile(),
      ),
    );
  }

  Future<List<DocumentSnapshot>> _loadPosts() async {
    final List<DocumentSnapshot> posts =
        await _postService.getListPostByUserId(widget.uid);
    for (var post in posts) {
      _listUidOfPosts.add(post[DocumentFieldNames.uid]);
    }
    return posts;
  }

  void _loadFeaturedStories() async {
    final stories =
        await _featuredStoryServices.getFeaturedStoriesByUserId(widget.uid);
    _featuredStoriesId =
        stories.map((featuredStory) => featuredStory.id).toList();
    _featuredStories = stories
        .map((featuredStory) =>
            FeaturedStory.fromMap(featuredStory.data() as Map<String, dynamic>))
        .toList();
    setState(() {});
  }

  Future<int> _loadFriends() async {
    final friends =
        await _friendRequestsServices.getCountFriendsByUserId(widget.uid);
    return friends;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.user.username ?? 'Unknown user',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).colorScheme.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 140.0,
                      height: 140.0,
                      child: CachedNetworkImage(
                        imageUrl: widget.user.imageProfile ??
                            'https://theatrepugetsound.org/wp-content/uploads/2023/06/Single-Person-Icon.png',
                        imageBuilder: (context, imageProvider) {
                          return SizedBox(
                            height: 140.0,
                            width: 140.0,
                            child: GestureDetector(
                              onTap: () => navigateToScreenAnimationRightToLeft(
                                  context,
                                  PhotoViewPageComponent(
                                    imageProvider: imageProvider,
                                  )),
                              child: Container(
                                width: 140.0,
                                height: 140.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder(
                        future: _futurePosts,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error --->: ${snapshot.error}'));
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const LoadingFlickrComponent();
                          }
                          final listPostId =
                              snapshot.data!.map((post) => post.id).toList();

                          return GestureDetector(
                            onTap: () {
                              navigateToScreenAnimationRightToLeft(
                                  context,
                                  PostDetailScreen(
                                    listPostId: listPostId,
                                    indexPost: listPostId.first.length,
                                    listUid: _listUidOfPosts,
                                  ));
                            },
                            child: Column(
                              children: [
                                Text(
                                  "Post",
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text("${listPostId.length}"),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<int>(
                          future: _futureFriends,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error --->: ${snapshot.error}'));
                            } else if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const LoadingFlickrComponent();
                            }
                            final countFriends = snapshot.data;
                            return GestureDetector(
                              onTap: () => navigateToScreenAnimationRightToLeft(
                                  context,
                                  ListFriendScreen(
                                    uid: widget.uid,
                                    allowPress: false,
                                  )),
                              child: Column(
                                children: [
                                  Text(
                                    "Friends",
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text("$countFriends"),
                                ],
                              ),
                            );
                          }),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: Text(
                        widget.user.username ?? 'Not name',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      child: Text(
                        widget.user.description ?? 'Not description',
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              StreamBuilder<bool?>(
                stream: _friendRequestsServices.checkFriendRequests(widget.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingFlickrComponent();
                  } else {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final isFriendRequest = snapshot.data;
                      //ignore:avoid_print
                      print('---> result display button: $isFriendRequest');
                      if (_currentUser!.uid == widget.uid) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: ButtonDefaultComponent(
                                  text: 'Edit profile',
                                  onTap: _editProfile,
                                  colorBackground:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              if (isFriendRequest == true)
                                Expanded(
                                  child: ButtonDefaultComponent(
                                    text: 'Unfriend',
                                    onTap: () => _dialogBuilder(
                                        context, 'You want unfriend?', () {
                                      _friendRequestsServices
                                          .unfriend(widget.uid);
                                      Navigator.pop(context);
                                    }, () => Navigator.pop(context), 'Unfriend',
                                        'Cancel'), // dialogBuilder
                                    colorBackground:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                )
                              else if (isFriendRequest == false)
                                Expanded(
                                  child: ButtonDefaultComponent(
                                    text: 'Cancel request',
                                    onTap: () => _dialogBuilder(
                                        context, 'Cancel friend request?', () {
                                      _friendRequestsServices
                                          .cancelRequestAddFriend(widget.uid);
                                      Navigator.pop(context);
                                    },
                                        () => Navigator.pop(context),
                                        'Cancel request',
                                        'Close'), // dialogBuilder
                                    colorBackground:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                )
                              else if (isFriendRequest == null)
                                Expanded(
                                  child: ButtonDefaultComponent(
                                    text: 'Add friend',
                                    onTap: () => _friendRequestsServices
                                        .sentRequestAddFriend(widget.uid),
                                    colorBackground:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }
                    }
                  }
                },
              ),
              _featuredStories.isNotEmpty
                  ? _buildListStory()
                  : const SizedBox.shrink(),
              SizedBox(
                height: 345.0,
                child: _buildListPost(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListPost() {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _futurePosts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingFlickrComponent();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error --->: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final listPostId = snapshot.data!.map((post) => post.id).toList();
          final listPosts = snapshot.data!
              .map((post) => Posts.fromMap(post.data() as Map<String, dynamic>))
              .toList();

          return GridView.builder(
            padding: EdgeInsets.zero,
            itemCount: listPosts.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => navigateToScreenAnimationRightToLeft(
                    context,
                    PostDetailScreen(
                      listPostId: listPostId,
                      indexPost: index,
                      listUid: _listUidOfPosts,
                    )),
                child: _buildGridItem(listPosts[index]),
              );
            },
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildGridItem(Posts post) {
    if (post.mediaLink!.isEmpty) {
      return _buildImage(
          'https://t4.ftcdn.net/jpg/04/73/25/49/360_F_473254957_bxG9yf4ly7OBO5I0O5KABlN930GwaMQz.jpg');
    } else {
      final path = post.mediaLink!.first;
      final extension = _getExtension(path);
      if (extension == 'jpg' || extension == 'png' || extension == 'jpeg') {
        return _buildImage(path);
      } else if (extension == 'mp4') {
        return _buildVideoThumbnail(path);
      }
    }
    return const SizedBox.shrink();
  }

  String _getExtension(String path) {
    final listPart = path.split('.');
    final lastPart = listPart.last.toLowerCase().split('?');
    return lastPart.first;
  }

  Widget _buildImage(String imageUrl) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
              width: 0.2, color: Theme.of(context).colorScheme.background),
        ),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.primary,
            highlightColor: Theme.of(context).colorScheme.secondary,
            child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Theme.of(context).colorScheme.background),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          fit: BoxFit.cover,
        ));
  }

  Widget _buildVideoThumbnail(String videoPath) {
    return FutureBuilder<File>(
      future: _imageServices.generateThumbnail(videoPath),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.primary,
            highlightColor: Theme.of(context).colorScheme.secondary,
            child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Theme.of(context).colorScheme.background),
          );
        } else {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                  width: 0.2, color: Theme.of(context).colorScheme.background),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: FileImage(snapshot.data!),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildListStory() {
    return SizedBox(
      height: 100.0,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _featuredStories.length,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () => navigateToScreenAnimationRightToLeft(
                context,
                StoryComponentScreen(
                  featuredStoryId: _featuredStoriesId[index],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 37.0,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: CircleAvatar(
                      radius: 34.0,
                      backgroundColor: Theme.of(context).colorScheme.background,
                      child: _featuredStories[index]
                                  .imageUrl
                                  .split('.')
                                  .last
                                  .split('?')
                                  .first ==
                              'jpg'
                          ? CircleAvatar(
                              radius: 32.0,
                              backgroundImage: CachedNetworkImageProvider(
                                  _featuredStories[index].imageUrl),
                            )
                          : CircleAvatar(
                              radius: 32.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32.0),
                                child: ThumbnailStoryVideoComponent(
                                  videoPath: _featuredStories[index].imageUrl,
                                ),
                              ),
                            ),
                    ),
                  ),
                  Text(
                    _featuredStories[index].featuredStoryDescription != ''
                        ? _featuredStories[index].featuredStoryDescription
                        : 'Featured story',
                    style: Theme.of(context).textTheme.labelSmall,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _dialogBuilder(
      BuildContext context,
      String title,
      void Function()? onYes,
      void Function()? onCancel,
      String labelStatusYes,
      String labelStatusCancel) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: Alignment.center,
          actionsAlignment: MainAxisAlignment.center,
          title: Text(title),
          actions: [
            Column(
              children: [
                const Divider(
                  height: 1.0,
                ),
                InkWell(
                  onTap: onYes,
                  child: Container(
                    width: double.infinity,
                    height: 55.0,
                    alignment: Alignment.center,
                    child: Text(
                      labelStatusYes,
                      style: const TextStyle(
                          color: AppColors.infoColor, fontSize: 16.0),
                    ),
                  ),
                ),
                const Divider(
                  height: 1.0,
                ),
                InkWell(
                  onTap: onCancel,
                  child: Container(
                    width: double.infinity,
                    height: 55.0,
                    alignment: Alignment.center,
                    child: Text(
                      labelStatusCancel,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.infoColor,
                          fontSize: 16.0),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
