import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/screens/login/login.dart';
import 'package:social_media_app/serviecs/Authentication/auth_services.dart';
import 'package:social_media_app/utils/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  singOutWithGoogle() async {
    final AuthenticationServices auth = AuthenticationServices();
    await auth.singOutUser();

    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: currentUser?.displayName != ''
                      ? currentUser?.displayName
                      : 'Set username',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 24.0),
                ),
                const WidgetSpan(child: Icon(Icons.keyboard_arrow_down_rounded))
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
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 140.0,
                      height: 140.0,
                      child: CircleAvatar(
                        backgroundImage: const AssetImage(
                            'assets/images/personal_image_default.png'),
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: showSignOutSnackBar,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30.0),
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
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
