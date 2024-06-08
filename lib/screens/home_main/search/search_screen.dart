import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:social_media_app/components/list/list_tile_user.dart';
import 'package:social_media_app/components/loading/loading_flickr.component.dart';
import 'package:social_media_app/models/posts.dart';
import 'package:social_media_app/screens/home_main/home_main.dart';
import 'package:social_media_app/screens/home_main/profile/post_details_screen.dart';
import 'package:social_media_app/screens/home_main/search/profile_users_screen.dart';
import 'package:social_media_app/services/images/images.services.dart';
import 'package:social_media_app/services/posts/post.services.dart';
import 'package:social_media_app/services/users/user.services.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/field_names.dart';
import 'package:social_media_app/utils/my_enum.dart';
import 'package:social_media_app/utils/navigate.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchQueryController = TextEditingController();
  final UserServices _userServices = UserServices();
  final PostService _postService = PostService();
  final ImageServices _imageServices = ImageServices();
  final _currentUser = FirebaseAuth.instance.currentUser;
  List _allResults = [];
  List _resultUsers = [];
  List<Posts> _resultPosts = [];
  List<String> _resultPostsId = [];
  List<String> _resultUserIdOfPosts = [];
  @override
  void initState() {
    super.initState();
    _getUsersStream();
    _searchQueryController.addListener(_onSearchUsersChanged);
    _searchQueryController.addListener(_onSearchPostsChanged);
  }

  @override
  void dispose() {
    _searchQueryController.dispose();
    super.dispose();
  }

  Future<void> getUserDetails(String docID) async {
    try {
      final user = await _userServices.getUserDetailsByID(docID);
      if (mounted) {
        if (docID == _currentUser!.uid) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const HomeMain(fragment: Fragments.profileScreen)),
              (route) => false);
        } else {
          navigateToScreenAnimationRightToLeft(
              context, ProfileUsersScreen(user: user!, uid: docID));
        }
      }
    } catch (error) {
      // ignore: avoid_print
      print("getUserDetails ERROR ---> $error");
    }
  }

  void _onSearchUsersChanged() {
    _searchResultList();
  }

  void _onSearchPostsChanged() {
    _searchPosts(_searchQueryController.text);
  }

  void _searchResultList() {
    var showResults = [];
    if (_searchQueryController.text != "") {
      for (var data in _allResults) {
        final username =
            data[DocumentFieldNames.username].toString().toLowerCase();
        final description =
            data[DocumentFieldNames.description].toString().toLowerCase();
        if (username.contains(_searchQueryController.text.toLowerCase()) ||
            description.contains(_searchQueryController.text.toLowerCase())) {
          showResults.add(data);
        }
      }
    } else {
      showResults = List.from(_allResults);
    }
    setState(() {
      _resultUsers = showResults;
    });
  }

  void _searchPosts(String query) async {
    List<Posts> dummyPosts = [];
    List<String> dummyPostIds = [];
    List<String> dummyUidOfPosts = [];
    await _postService.searchPosts(query).then((posts) => {
          dummyPosts = posts.docs
              .map((post) => Posts.fromMap(post.data() as Map<String, dynamic>))
              .toList(),
          dummyPostIds = posts.docs.map((post) => post.id).toList(),
        });
    if (dummyPosts.isNotEmpty) {
      for (var post in dummyPosts) {
        dummyUidOfPosts.add(post.uid!);
      }
    }
    setState(() {
      _resultPosts = dummyPosts;
      _resultPostsId = dummyPostIds;
      _resultUserIdOfPosts = dummyUidOfPosts;
    });
  }

  void _getUsersStream() async {
    final data = await _userServices.getUsersOrderyByUsername();
    setState(() {
      _allResults = data.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: CupertinoSearchTextField(
            controller: _searchQueryController,
            keyboardType: TextInputType.multiline,
          ),
          bottom: const TabBar(
            labelColor: Colors.amber,
            indicatorColor: Colors.amber,
            tabs: [
              Tab(
                icon: Icon(Icons.people_alt_outlined),
              ),
              Tab(
                icon: Icon(Icons.grid_on_rounded),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                Expanded(child: _buildSearchUsersResult()),
              ],
            ),
            Column(
              children: [
                Expanded(child: _buildSearchPostsResult()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchUsersResult() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _resultUsers.length,
      itemBuilder: (context, index) {
        final username = _resultUsers[index][DocumentFieldNames.username];
        final description = _resultUsers[index][DocumentFieldNames.description];
        final imageProfile =
            _resultUsers[index][DocumentFieldNames.imageProfile];
        final documentData = _resultUsers[index];
        return ListTileComponent(
          username: username,
          subtitle: description,
          imageUrl: imageProfile,
          onTap: () => getUserDetails(documentData.id),
        );
      },
    );
  }

  Widget _buildSearchPostsResult() {
    return MasonryGridView.builder(
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      mainAxisSpacing: 1.0,
      crossAxisSpacing: 1.0,
      itemCount: _resultPosts.length,
      itemBuilder: (context, index) {
        final post = _resultPosts[index];
        if (post.mediaLink!.isNotEmpty) {
          if (post.mediaLink!.first.contains('.jpg')) {
            return GestureDetector(
              onTap: () {
                navigateToScreenAnimationRightToLeft(
                  context,
                  PostDetailScreen(
                    listPostId: _resultPostsId,
                    indexPost: index,
                    listUid: _resultUserIdOfPosts,
                  ),
                );
              },
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: _buildImage(post.mediaLink!.first),
              ),
            );
          } else if (post.mediaLink!.first.contains('.mp4')) {
            return GestureDetector(
              onTap: () {
                navigateToScreenAnimationRightToLeft(
                  context,
                  PostDetailScreen(
                    listPostId: _resultPostsId,
                    indexPost: index,
                    listUid: _resultUserIdOfPosts,
                  ),
                );
              },
              child: AspectRatio(
                aspectRatio: 1 / 2,
                child: Column(
                  children: [
                    Expanded(
                        child: _buildVideoThumbnail(post.mediaLink!.first)),
                  ],
                ),
              ),
            );
          } else {
            return const Text('ERROR');
          }
        } else {
          return Text(post.postText!);
        }
      },
    );
  }

  Widget _buildImage(String imageUrl) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
              width: 0.2, color: Theme.of(context).colorScheme.background),
        ),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) => const LoadingFlickrComponent(),
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
          return const LoadingFlickrComponent();
        } else {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.2,
                    color: Theme.of(context).colorScheme.background,
                  ),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(snapshot.data!),
                  ),
                ),
              ),
              const Positioned(
                bottom: 5.0,
                left: 5.0,
                child: Icon(
                  Icons.video_library_outlined,
                  color: AppColors.backgroundColor,
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
