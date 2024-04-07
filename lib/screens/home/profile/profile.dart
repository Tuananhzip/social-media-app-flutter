import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/screens/login/login.dart';
import 'package:social_media_app/serviecs/Authentication/google_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});
  final User user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  singOutWithGoogle() async {
    AuthenticationSocialMediaApp auth = AuthenticationSocialMediaApp();
    await auth.singOutWithGoogle();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: TextButton(
                onPressed: singOutWithGoogle, child: const Text("Sign out")),
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
        body: Text(widget.user.email!),
      ),
    );
  }
}
