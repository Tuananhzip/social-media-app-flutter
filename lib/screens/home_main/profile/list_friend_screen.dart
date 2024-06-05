import 'package:flutter/material.dart';
import 'package:social_media_app/components/list/list_friend_request.component.dart';
import 'package:social_media_app/components/loading/loading_flickr.component.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/screens/home_main/search/profile_users_screen.dart';
import 'package:social_media_app/services/friendRequests/friend_request.services.dart';
import 'package:social_media_app/utils/navigate.dart';

class ListFriendScreen extends StatefulWidget {
  const ListFriendScreen({
    super.key,
    required this.uid,
    this.allowPress = true,
  });
  final String uid;
  final bool allowPress;

  @override
  State<ListFriendScreen> createState() => _ListFriendScreenState();
}

class _ListFriendScreenState extends State<ListFriendScreen> {
  final FriendRequestsServices _friendRequestsServices =
      FriendRequestsServices();
  final List<Users> _listFriends = [];
  final List<String> _listFriendIds = [];
  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  void _fetchFriends() async {
    final listFriend =
        await _friendRequestsServices.getListFriendByUserId(widget.uid);
    if (listFriend.isNotEmpty) {
      final listFriendIds = listFriend.map((friend) => friend.id).toList();
      final listFriendData = listFriend
          .map((friend) => Users.fromMap(friend.data() as Map<String, dynamic>))
          .toList();
      setState(() {
        _listFriendIds.addAll(listFriendIds);
        _listFriends.addAll(listFriendData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends"),
        centerTitle: true,
      ),
      body: _listFriends.isNotEmpty
          ? ListView.builder(
              itemCount: _listFriends.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.85),
                  child: GestureDetector(
                    onTap: !widget.allowPress
                        ? null
                        : () => navigateToScreenAnimationRightToLeft(
                            context,
                            ProfileUsersScreen(
                                user: _listFriends[index],
                                uid: _listFriendIds[index])),
                    child: ListTileFriendRequestComponent(
                      listImages: [_listFriends[index].imageProfile],
                      title: _listFriends[index].username,
                      listTrailing: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: OutlinedButton(
                            child: Text(
                              'Unfriend',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            onPressed: () {
                              _friendRequestsServices
                                  .unfriend(_listFriendIds[index]);
                              setState(() {
                                _listFriends.removeAt(index);
                                _listFriendIds.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : const LoadingFlickrComponent(),
    );
  }
}
