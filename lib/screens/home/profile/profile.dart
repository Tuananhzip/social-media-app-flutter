import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:social_media_app/models/Users.dart';
import 'package:social_media_app/screens/components/button/button_default.dart';
import 'package:social_media_app/screens/components/list_post/list_post.dart';
import 'package:social_media_app/screens/components/story/story_screen.dart';
import 'package:social_media_app/screens/home/profile/update_profile.dart';
import 'package:social_media_app/screens/login/login.dart';
import 'package:social_media_app/serviecs/Authentication/auth_services.dart';
import 'package:social_media_app/serviecs/Images/images_services.dart';
import 'package:social_media_app/serviecs/Users/user_services.dart';
import 'package:social_media_app/utils/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final UserServices userServices = UserServices();
  Users user = Users(email: FirebaseAuth.instance.currentUser!.email!);

  bool isImageLoading = false;

  @override
  initState() {
    super.initState();
    getUserData();
  }

  Future getUserData() async {
    await userServices.fetchDataUserInfo();
  }

  Future<void> singOutWithGoogle() async {
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

  Future<void> updateImageProfile() async {
    setState(() {
      isImageLoading = true;
    });
    final ImageServices imageService = ImageServices();
    try {
      await imageService.updateProfileImage();
    } catch (error) {
      // ignore: avoid_print
      print("Update Image Profile User ERROR (updateImageProfile) ---> $error");
    } finally {
      setState(() {
        isImageLoading = false;
      });
    }
  }

  showSignOutSnackBar() {
    final snackBar = SnackBar(
      content: Text("Do you want to sign out? '${currentUser?.email}' "),
      action: SnackBarAction(
        label: 'Sign out',
        onPressed: singOutWithGoogle,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UpdateProfile(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: userServices.getUserStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic> userData =
              snapshot.data!.data() as Map<String, dynamic>;
          user = Users.formMap(userData);
          print(user.toString());
          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  title: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: currentUser?.displayName ?? 'Set username',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24.0),
                      ),
                      WidgetSpan(
                          child: GestureDetector(
                        onTap: showSignOutSnackBar,
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
              ],
              body: Container(
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
                              backgroundImage: user.imageProfile!.isNotEmpty &&
                                      !isImageLoading
                                  ? NetworkImage(user.imageProfile!)
                                  : currentUser!.photoURL != null &&
                                          !isImageLoading
                                      ? NetworkImage(currentUser!.photoURL!)
                                      : const NetworkImage(
                                          "https://theatrepugetsound.org/wp-content/uploads/2023/06/Single-Person-Icon.png"),
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: updateImageProfile,
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        width: 40.0,
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
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
                                  Visibility(
                                    visible: isImageLoading,
                                    child: const Align(
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                ],
                              ),
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
                              currentUser?.displayName ?? 'Hello name',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0,
                              ),
                            ),
                          ),
                          SizedBox(
                            child: Text(
                              currentUser?.displayName ?? 'Hello name',
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
                            child: ButtonDefault(
                              text: 'Edit profile',
                              onTap: editProfile,
                              colorBackground:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(
                            width: 16.0,
                          ),
                          Expanded(
                              child: ButtonDefault(
                            onTap: () {},
                            icon: Icons.person_add_alt_rounded,
                            colorBackground:
                                Theme.of(context).colorScheme.primary,
                          ))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16.0),
                      child: SizedBox(
                        height: 115,
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
                                "https://letsenhance.io/static/8f5e523ee6b2479e26ecc91b9c25261e/1015f/MainAfter.jpg";
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
                    const Expanded(child: ListPost())
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget buildListItemStory(BuildContext context, int index, String imageUser,
      String lastNameOverflow, bool statusStory) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StoryScreen(userName: lastNameOverflow)));
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
}
