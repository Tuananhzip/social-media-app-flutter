import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/list/list_tile_user.dart';
import 'package:social_media_app/components/loading/loading_flickr.component.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/screens/home_main/home_screen/message_screen/chat_screen.dart';
import 'package:social_media_app/services/friendRequests/friend_request.services.dart';
import 'package:social_media_app/services/notifications/notifications.services.dart';
import 'package:social_media_app/services/users/user.services.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/navigate.dart';

class ListMessageScreen extends StatefulWidget {
  const ListMessageScreen({super.key});

  @override
  State<ListMessageScreen> createState() => _ListMessageScreenState();
}

class _ListMessageScreenState extends State<ListMessageScreen> {
  final UserServices _userServices = UserServices();
  final NotificationServices _notificationServices = NotificationServices();
  final FriendRequestsServices _friendRequestsServices =
      FriendRequestsServices();
  final _currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _searchController = TextEditingController();
  Users? _user;
  final List<Users> _listFriends = [];
  final List<String> _listFriendIds = [];
  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  void _fetchFriends() async {
    try {
      if (_currentUser != null) {
        _user = await _userServices.getUserDetailsByID(_currentUser.uid);
        final listFriend = await _friendRequestsServices
            .getListFriendByUserId(_currentUser.uid);

        if (listFriend.isNotEmpty) {
          final listFriendIds = listFriend.map((friend) => friend.id).toList();

          final listFriendData = listFriend.map((friend) {
            return Users.fromMap(friend.data() as Map<String, dynamic>);
          }).toList();

          setState(() {
            _listFriendIds.addAll(listFriendIds);
            _listFriends.addAll(listFriendData);
          });
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching friends: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _user?.username ?? '...',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CupertinoSearchTextField(
              controller: _searchController,
              keyboardType: TextInputType.multiline,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              'Messages',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          _listFriends.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _listFriends.length,
                    itemBuilder: (context, index) {
                      return StreamBuilder<bool>(
                          stream: _notificationServices
                              .checkNotificationMessageForUser(
                                  _listFriendIds[index]),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Center(child: Text('Error'));
                            }

                            return GestureDetector(
                              onTap: () {
                                _notificationServices
                                    .markAsSeenNotificationMessage(
                                        _listFriendIds[index]);
                                navigateToScreenAnimationRightToLeft(
                                  context,
                                  ChatScreen(
                                      recipientId: _listFriendIds[index]),
                                );
                              },
                              child: ListTileComponent(
                                username:
                                    _listFriends[index].username ?? 'Unknown',
                                imageUrl: _listFriends[index].imageProfile,
                                subtitle: _listFriends[index].description ?? '',
                                trailingWidget: snapshot.data == true
                                    ? const Icon(
                                        Icons.circle,
                                        color: AppColors.blueColor,
                                        size: 12.0,
                                      )
                                    : null,
                              ),
                            );
                          });
                    },
                  ),
                )
              : const LoadingFlickrComponent(),
        ],
      ),
    );
  }
}
