import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/screens/login/login.dart';
import 'package:social_media_app/serviecs/Authentication/auth_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  singOutWithGoogle() async {
    AuthenticationServices auth = AuthenticationServices();
    await auth.singOutUser();

    // ignore: use_build_context_synchronously
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
        body: Text("${currentUser!.email}"),
      ),
    );
  }
}
