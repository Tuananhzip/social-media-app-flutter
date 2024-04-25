import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/button/button_default.component.dart';
import 'package:social_media_app/components/list/list_post.component.dart';
import 'package:social_media_app/components/loading/overlay_loading.component.dart';
import 'package:social_media_app/components/story/story_screen.component.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/screens/home_main/profile/update_profile_screen.dart';
import 'package:social_media_app/services/friendRequests/friend_request.services.dart';
import 'package:social_media_app/utils/app_colors.dart';

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
  final currentUser = FirebaseAuth.instance.currentUser;
  final FriendRequestsServices friendRequestsServices =
      FriendRequestsServices();
  @override
  void initState() {
    super.initState();
  }

  void editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UpdateProfile(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.user.username ?? 'Hello name'),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
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
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(widget
                                .user.imageProfile ??
                            'https://theatrepugetsound.org/wp-content/uploads/2023/06/Single-Person-Icon.png'),
                      ),
                    ),
                    const Expanded(
                      child: Column(
                        children: [
                          Text(
                            "Post",
                            style: TextStyle(fontSize: 22.0),
                          ),
                          Text("202"),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: Column(
                        children: [
                          Text(
                            "Friends",
                            style: TextStyle(fontSize: 22.0),
                          ),
                          Text("12"),
                        ],
                      ),
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
                stream: friendRequestsServices.checkFriendRequests(widget.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const OverlayLoadingWidget();
                  } else {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final isFriendRequest = snapshot.data;
                      //ignore:avoid_print
                      print('---> result display button: $isFriendRequest');
                      if (currentUser!.uid == widget.uid) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: ButtonDefaultComponent(
                                  text: 'Edit profile',
                                  onTap: editProfile,
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
                                    onTap: () => {},
                                    colorBackground:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                )
                              else if (isFriendRequest == false)
                                Expanded(
                                  child: ButtonDefaultComponent(
                                    text: 'Cancel request',
                                    onTap: () => dialogBuilder(
                                        context, 'Cancel friend request?', () {
                                      friendRequestsServices
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
                                    onTap: () => friendRequestsServices
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
                child: SizedBox(
                  height: 115,
                  child: ListView.builder(
                    itemCount: 15,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      bool statusStory = false;
                      String userName = "Trần Ngọc Khánhsdsada";
                      List<String> nameParts = userName.split(' ');
                      String lastName =
                          nameParts.isNotEmpty ? nameParts.last : userName;
                      String lastNameOverflow = lastName.length > 8
                          ? '${lastName.substring(0, 6)}...'
                          : lastName;
                      String imageUser =
                          "https://cdn.vn.alongwalk.info/vn/wp-content/uploads/2023/02/13190852/image-99-hinh-anh-con-bo-sua-cute-che-dang-yeu-dep-me-hon-2023-167626493122484.jpg";
                      return buildListItemStory(
                        context,
                        index,
                        imageUser,
                        lastNameOverflow,
                        statusStory,
                      ); // username, status story video (User and VideoStories)
                    },
                  ),
                ),
              ),
              const Flexible(child: ListPostComponent())
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListItemStory(BuildContext context, int index, String imageUser,
      String lastNameOverflow, bool statusStory) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    StoryComponent(userName: lastNameOverflow)));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: statusStory == true ? Colors.grey : Colors.blue,
                  width: 4.0,
                ),
                image: DecorationImage(
                  image: NetworkImage(imageUser),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(
              lastNameOverflow,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            )
          ],
        ),
      ),
    );
  }

  Future<void> dialogBuilder(
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
