import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media_app/components/loading/loading_flickr.component.dart';
import 'package:social_media_app/components/button/button_default.component.dart';
import 'package:social_media_app/components/story/story_screen.component.dart';
import 'package:social_media_app/components/story/thumbnail_story_video.component.dart';
import 'package:social_media_app/components/view/photo_view_page.component.dart';
import 'package:social_media_app/models/featured_story.dart';
import 'package:social_media_app/models/posts.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/screens/home_main/create_post/create_post_screen.dart';
import 'package:social_media_app/screens/home_main/create_post/create_story/create_story_screen.dart';
import 'package:social_media_app/screens/home_main/profile/post_details_screen.dart';
import 'package:social_media_app/screens/home_main/profile/add_featured_stories.dart';
import 'package:social_media_app/screens/home_main/profile/list_friend_screen.dart';
import 'package:social_media_app/screens/home_main/profile/update_profile_screen.dart';
import 'package:social_media_app/screens/login/login.dart';
import 'package:social_media_app/services/authentication/authentication.services.dart';
import 'package:social_media_app/services/featuredStories/featured_story.service.dart';
import 'package:social_media_app/services/friendRequests/friend_request.services.dart';
import 'package:social_media_app/services/images/images.services.dart';
import 'package:social_media_app/services/posts/post.services.dart';
import 'package:social_media_app/services/users/user.services.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/navigate.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _currentUser = FirebaseAuth.instance.currentUser;
  final UserServices _userServices = UserServices();
  final PostService _postService = PostService();
  final FriendRequestsServices _friendRequestsServices =
      FriendRequestsServices();

  final FeaturedStoryServices _featuredStoryServices = FeaturedStoryServices();
  final ImageServices _imageServices = ImageServices();

  Users _user = Users(email: FirebaseAuth.instance.currentUser!.email!);
  late Future<List<DocumentSnapshot>> _futurePosts;
  late Future<int> _futureFriends;
  bool _isImageLoading = false;
  List<FeaturedStory> _featuredStories = [];
  List<String> _featuredStoriesId = [];

  @override
  initState() {
    super.initState();
    _futurePosts = _loadPosts();
    _futureFriends = _loadFriends();
    _loadFeaturedStories();
  }

  Future<List<DocumentSnapshot>> _loadPosts() async {
    final List<DocumentSnapshot> posts =
        await _postService.getListPostForCurrentUser();
    return posts;
  }

  Future<int> _loadFriends() async {
    final friends =
        await _friendRequestsServices.getCountFriendsByCurrentUser();
    return friends;
  }

  void _loadFeaturedStories() async {
    final stories =
        await _featuredStoryServices.getFeaturedStoriesForCurrentUser();
    _featuredStoriesId =
        stories.map((featuredStory) => featuredStory.id).toList();
    _featuredStories = stories
        .map((featuredStory) =>
            FeaturedStory.fromMap(featuredStory.data() as Map<String, dynamic>))
        .toList();
    setState(() {});
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _futurePosts = _loadPosts();
      _futureFriends = _loadFriends();
      _loadFeaturedStories();
    });
  }

  Future<void> _singOutWithGoogle() async {
    final AuthenticationServices auth = AuthenticationServices();
    try {
      await auth.singOutUser();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (route) => false);
      }
    } catch (error) {
      // ignore: avoid_print
      print("Sign Out ERROR (singOutUser) ---> $error");
    }
  }

  Future<void> _updateImageProfile() async {
    setState(() {
      _isImageLoading = true;
    });
    final ImageServices imageService = ImageServices();
    try {
      await imageService.updateImageProfile();
    } catch (error) {
      // ignore: avoid_print
      print("Update Image Profile User ERROR (updateImageProfile) ---> $error");
    } finally {
      setState(() {
        _isImageLoading = false;
      });
    }
  }

  void _showSignOutSnackBar() {
    final snackBar = SnackBar(
      content: Text("Do you want to sign out? '${_currentUser?.email}' "),
      action: SnackBarAction(
        label: 'Sign out',
        onPressed: _singOutWithGoogle,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _editProfile() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => const UpdateProfile(),
    //   ),
    // );
    navigateToScreenAnimationRightToLeft(context, const UpdateProfile());
  }

  String? _getUsername() {
    if (_user.username != '' && _user.username != null) {
      return _user.username;
    } else if (_currentUser!.displayName != '' &&
        _currentUser.displayName != null) {
      return _currentUser.displayName;
    } else {
      return "Hello name";
    }
  }

  String? _getEmail() {
    if (_currentUser != null) {
      return _currentUser.email?.split('@').first;
    } else {
      return 'Email not found';
    }
  }

  String _getImageProfile() {
    if (_user.imageProfile != null && _user.imageProfile != '') {
      return _user.imageProfile!;
    } else if (_currentUser!.photoURL != null && _currentUser.photoURL != '') {
      return _currentUser.photoURL!;
    } else {
      return 'https://theatrepugetsound.org/wp-content/uploads/2023/06/Single-Person-Icon.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userServices.getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error --->: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.data() != null) {
          final Map<String, dynamic> userData =
              snapshot.data!.data() as Map<String, dynamic>;
          _user = Users.fromMap(userData);
          final Logger logger = Logger();
          logger.i(_user);
        }

        return Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: _showSignOutSnackBar,
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: _getEmail(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const WidgetSpan(
                    child: Icon(Icons.keyboard_arrow_down_outlined),
                  )
                ]),
              ),
            ),
            actions: [
              IconButton(
                  onPressed: () => showCupertinoModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return SizedBox(
                            width: double.infinity,
                            height: 225.0,
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(16.0),
                                  width: 40.0,
                                  height: 5.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0),
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  'Create',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Divider(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        navigateToScreenAnimationRightToLeft(
                                      context,
                                      const CreatePostScreen(),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .background,
                                            child: Icon(
                                              Icons.grid_on_rounded,
                                              size: 36.0,
                                              color: Theme.of(context)
                                                          .colorScheme
                                                          .background ==
                                                      AppColors.backgroundColor
                                                  ? AppColors.blackColor
                                                  : AppColors.backgroundColor,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Text(
                                              'Post',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelLarge,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  color: Theme.of(context).colorScheme.primary,
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  height: 1.0,
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        navigateToScreenAnimationRightToLeft(
                                      context,
                                      const CreateStoryScreen(),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .background,
                                            child: Icon(
                                              Icons.add_circle_outline_rounded,
                                              size: 36.0,
                                              color: Theme.of(context)
                                                          .colorScheme
                                                          .background ==
                                                      AppColors.backgroundColor
                                                  ? AppColors.blackColor
                                                  : AppColors.backgroundColor,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Text(
                                              'Story',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelLarge,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  icon: const Icon(Icons.add_box_outlined)),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: IconButton(
                    onPressed: () => navigateToScreenAnimationRightToLeft(
                          context,
                          Container(),
                        ),
                    icon: const Icon(Icons.menu)),
              )
            ],
          ),
          key: _scaffoldKey,
          body: RefreshIndicator(
            onRefresh: _refreshPosts,
            child: SingleChildScrollView(
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
                              imageUrl: _getImageProfile(),
                              placeholder: (context, url) =>
                                  const LoadingFlickrComponent(),
                              imageBuilder: (context, imageProvider) {
                                return SizedBox(
                                  height: 140.0,
                                  width: 140.0,
                                  child: _isImageLoading
                                      ? const LoadingFlickrComponent()
                                      : Stack(
                                          children: [
                                            GestureDetector(
                                              onTap: () =>
                                                  navigateToScreenAnimationRightToLeft(
                                                      context,
                                                      PhotoViewPageComponent(
                                                        imageProvider:
                                                            imageProvider,
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
                                            Positioned(
                                              bottom: 5.0,
                                              right: 5.0,
                                              child: GestureDetector(
                                                onTap: _updateImageProfile,
                                                child: Container(
                                                  width: 32.0,
                                                  height: 32.0,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30.0),
                                                      color:
                                                          AppColors.blueColor),
                                                  child: const Icon(
                                                    Icons.add,
                                                    color: AppColors
                                                        .backgroundColor,
                                                    size: 24.0,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
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
                                      child: Text(
                                          'Error --->: ${snapshot.error}'));
                                } else if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const LoadingFlickrComponent();
                                }
                                final listPostId = snapshot.data!
                                    .map((post) => post.id)
                                    .toList();

                                return GestureDetector(
                                  onTap: () {
                                    navigateToScreenAnimationRightToLeft(
                                        context,
                                        PostDetailScreen(
                                          listPostId: listPostId,
                                          indexPost: listPostId.first.length,
                                        ));
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        "Post",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
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
                                        child: Text(
                                            'Error --->: ${snapshot.error}'));
                                  } else if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const LoadingFlickrComponent();
                                  }
                                  final countFriends = snapshot.data;
                                  return GestureDetector(
                                    onTap: () =>
                                        navigateToScreenAnimationRightToLeft(
                                            context, const ListFriendScreen()),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Friends",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            child: Text(
                              _getUsername()!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0,
                              ),
                            ),
                          ),
                          SizedBox(
                            child: Text(
                              _user.description ?? '',
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 280.0,
                            child: ButtonDefaultComponent(
                              text: 'Edit profile',
                              onTap: _editProfile,
                              colorBackground:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(
                            width: 16.0,
                          ),
                          Expanded(
                              child: ButtonDefaultComponent(
                            onTap: () => navigateToScreenAnimationRightToLeft(
                                context, const ListFriendScreen()),
                            icon: Icons.people_outline_rounded,
                            colorBackground:
                                Theme.of(context).colorScheme.primary,
                          ))
                        ],
                      ),
                    ),
                    _buildListStory(),
                    SizedBox(
                      height: 290.0,
                      child: _buildListPost(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
        itemCount: _featuredStories.length + 1,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _featuredStories.length == index
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: GestureDetector(
                      onTap: () => navigateToScreenAnimationRightToLeft(
                          context, const AddFeaturedStoryScreen()),
                      child: Container(
                        width: 70.0,
                        height: 70.0,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3.0,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.primary,
                          size: 30.0,
                        ),
                      ),
                    ),
                  )
                : GestureDetector(
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
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: CircleAvatar(
                            radius: 34.0,
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
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
                                        videoPath:
                                            _featuredStories[index].imageUrl,
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
}
