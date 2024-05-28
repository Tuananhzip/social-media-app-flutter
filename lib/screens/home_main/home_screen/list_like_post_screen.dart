import 'package:flutter/material.dart';
import 'package:social_media_app/components/list/list_friend_request.component.dart';
import 'package:social_media_app/components/loading/loading_flickr.component.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/screens/home_main/search/profile_users_screen.dart';
import 'package:social_media_app/services/postLikes/post_like.service.dart';
import 'package:social_media_app/services/users/user.services.dart';

class ListLikesScreen extends StatefulWidget {
  const ListLikesScreen({super.key, required this.postId});
  final String postId;

  @override
  State<ListLikesScreen> createState() => _ListLikesScreenState();
}

class _ListLikesScreenState extends State<ListLikesScreen> {
  final PostLikeServices _postLikeServices = PostLikeServices();
  final UserServices _userServices = UserServices();
  final List<Users?> _users = [];
  final List<String> _uids = [];
  @override
  void initState() {
    super.initState();
    _getListUserLiked();
  }

  Future<void> _getListUserLiked() async {
    final List<String> uids =
        await _postLikeServices.getUsersLikedPost(widget.postId);

    final List<Future<Users?>> userFutures =
        uids.map((uid) => _userServices.getUserDetailsByID(uid)).toList();
    final List<Users?> users = await Future.wait(userFutures);
    setState(() {
      _users.addAll(users);
      _uids.addAll(uids);
    });
  }

  Future<void> navigateToProfileUsersScreen(String uid) async {
    try {
      final user = await _userServices.getUserDetailsByID(uid);
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => ProfileUsersScreen(
            user: user!,
            uid: uid,
          ),
        ),
      );
    } catch (error) {
      // ignore: avoid_print
      print("getUserDetails ERROR ---> $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Likes'),
        centerTitle: true,
        titleTextStyle: Theme.of(context).textTheme.titleLarge,
      ),
      body: _users.isNotEmpty
          ? ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => navigateToProfileUsersScreen(_uids[index]),
                  child: ListTileFriendRequestComponent(
                    title: _users[index]?.username,
                    subtitle: _users[index]?.description,
                    listImages: [
                      _users[index]?.imageProfile,
                    ],
                  ),
                );
              },
            )
          : const LoadingFlickrComponent(),
    );
  }
}
