import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/screens/home/home_screen/home_screen.dart';
import 'package:social_media_app/screens/login/login.dart';
import 'package:social_media_app/utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser != null) {
      setState(() {
        isLoggedIn = true;
      });
    }
    // Check xem người dùng đã đăng nhập chưa sẽ chuyển qua những trang khác nhau
    Future.delayed(const Duration(milliseconds: 2000), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1000),
          pageBuilder: (context, animation1, animation2) =>
              isLoggedIn ? const HomeScreen() : const LoginScreen(),
          transitionsBuilder: (context, animation1, animation2, child) {
            return FadeTransition(
              opacity: animation1,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: Transform.scale(
            scale: 0.333,
            alignment: Alignment.center,
            child: Image.asset("assets/images/logo_social_media.png"),
          ),
        ),
        const Align(
          alignment: Alignment(0.0, 0.9),
          child: Text(
            "Tuananhzip © 2024 All Rights Reserved",
            style: TextStyle(
                fontFamily: 'Roboto',
                color: AppColors.blackColor,
                fontSize: 16.0),
          ),
        ),
      ],
    ));
  }
}
