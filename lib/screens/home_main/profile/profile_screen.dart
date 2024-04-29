import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:social_media_app/components/loading/overlay_loading.component.dart';
import 'package:social_media_app/components/button/button_default.component.dart';
import 'package:social_media_app/components/list/list_post.component.dart';
import 'package:social_media_app/components/story/story_screen.component.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/screens/home_main/profile/update_profile_screen.dart';
import 'package:social_media_app/screens/login/login.dart';
import 'package:social_media_app/services/authentication/authentication.services.dart';
import 'package:social_media_app/services/images/images.services.dart';
import 'package:social_media_app/services/users/user.services.dart';
import 'package:social_media_app/utils/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _currentUser = FirebaseAuth.instance.currentUser;
  final UserServices _userServices = UserServices();
  Users _user = Users(email: FirebaseAuth.instance.currentUser!.email!);

  bool _isImageLoading = false;

  Future<void> _singOutWithGoogle() async {
    final AuthenticationServices auth = AuthenticationServices();
    try {
      await auth.singOutUser();
    } catch (error) {
      // ignore: avoid_print
      print("Sign Out ERROR (singOutUser) ---> $error");
    }
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UpdateProfile(),
      ),
    );
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

  String _getImageProfile() {
    if (_user.imageProfile != null &&
        _user.imageProfile != '' &&
        !_isImageLoading) {
      return _user.imageProfile!;
    } else if (_currentUser!.photoURL != null && !_isImageLoading) {
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
          key: _scaffoldKey,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: _getUsername(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 24.0),
                    ),
                    WidgetSpan(
                        child: GestureDetector(
                      onTap: _showSignOutSnackBar,
                      child: const Icon(Icons.keyboard_arrow_down_outlined),
                    ))
                  ]),
                ),
                actions: [
                  IconButton(
                      onPressed: () => {},
                      icon: const Icon(Icons.add_box_outlined)),
                  IconButton(
                      onPressed: () => {},
                      icon: const Icon(Icons.notifications_none_outlined))
                ],
              ),
              SliverToBoxAdapter(
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
                              child: CachedNetworkImage(
                                imageUrl: _getImageProfile(),
                                placeholder: (context, url) =>
                                    const OverlayLoadingWidget(),
                                imageBuilder: (context, imageProvider) {
                                  return SizedBox(
                                    height: 140.0,
                                    width: 140.0,
                                    child: CircleAvatar(
                                      backgroundImage: imageProvider,
                                      child: Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: _updateImageProfile,
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: Container(
                                                width: 40.0,
                                                height: 40.0,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0),
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary),
                                                child: const Icon(
                                                  Icons.add,
                                                  color: AppColors.primaryColor,
                                                  size: 32.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
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
                              onTap: () {},
                              icon: Icons.person_add_alt_rounded,
                              colorBackground:
                                  Theme.of(context).colorScheme.primary,
                            ))
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 95.0,
                        child: ListView.builder(
                          itemCount: 15,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            bool statusStory = false;
                            String userName = "Trần Ngọc Khánhsdsada";
                            List<String> nameParts = userName.split(' ');
                            String lastName = nameParts.isNotEmpty
                                ? nameParts.last
                                : userName;
                            String lastNameOverflow = lastName.length > 8
                                ? '${lastName.substring(0, 6)}...'
                                : lastName;
                            String imageUser =
                                "https://cdn.vn.alongwalk.info/vn/wp-content/uploads/2023/02/13190852/image-99-hinh-anh-con-bo-sua-cute-che-dang-yeu-dep-me-hon-2023-167626493122484.jpg";
                            return _buildListItemStory(
                              context,
                              index,
                              imageUser,
                              lastNameOverflow,
                              statusStory,
                            ); // username, status story video (User and VideoStories)
                          },
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.grid_4x4_outlined),
                          ),
                        ),
                      ),
                      const Expanded(child: ListPostComponent())
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListItemStory(BuildContext context, int index, String imageUser,
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
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
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
}
