import 'package:flutter/material.dart';
import 'package:social_media_app/components/list/list_friend_request.component.dart';
import 'package:social_media_app/components/loading/overlay_loading.component.dart';
import 'package:social_media_app/models/friend_requests.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/services/friendRequests/friend_request.services.dart';
import 'package:social_media_app/services/users/user.services.dart';

class ListFriendRequestScreen extends StatefulWidget {
  const ListFriendRequestScreen({super.key});

  @override
  State<ListFriendRequestScreen> createState() =>
      _ListFriendRequestScreenState();
}

class _ListFriendRequestScreenState extends State<ListFriendRequestScreen> {
  final FriendRequestsServices _friendRequestsServices =
      FriendRequestsServices();
  final UserServices _userServices = UserServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Friend requests"),
          centerTitle: true,
        ),
        body: StreamBuilder<List<FriendRequest>>(
          stream: _friendRequestsServices.getFriendRequests(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('ERROR ---> ${snapshot.error}'),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const OverlayLoadingWidget();
            } else {
              final dataListFriendRequest = snapshot.data;
              if (dataListFriendRequest != null &&
                  dataListFriendRequest.isNotEmpty) {
                return ListView.builder(
                  itemCount: dataListFriendRequest.length,
                  itemBuilder: (context, index) {
                    final friendRequest = dataListFriendRequest[index];
                    return FutureBuilder<Users?>(
                      future: _userServices
                          .getUserDetailsByID(friendRequest.senderId),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const OverlayLoadingWidget();
                        } else if (userSnapshot.hasError) {
                          return Center(
                            child: Text(
                                "ERROR USERSNAPSHOT ---> ${userSnapshot.error}"),
                          );
                        } else if (userSnapshot.hasData) {
                          final user = userSnapshot.data;
                          return ListTileFriendRequestComponent(
                            subtitle: user!.username!,
                            listImages: [user.imageProfile],
                            listTrailing: [
                              ElevatedButton(
                                onPressed: () => _friendRequestsServices
                                    .acceptRequestAddFriend(
                                        friendRequest.senderId),
                                child: Text(
                                  "Confirm",
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () => _friendRequestsServices
                                    .deleteRequestAddFriend(
                                        friendRequest.senderId),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                child: Text(
                                  "Delete",
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const ListTileFriendRequestComponent(
                            subtitle: 'Not found USERS for friend request',
                            listImages: [],
                          );
                        }
                      },
                    );
                  },
                );
              } else {
                return const ListTileFriendRequestComponent(
                  subtitle: 'Not found friend request',
                  listImages: [],
                );
              }
            }
          },
        ));
  }
}
