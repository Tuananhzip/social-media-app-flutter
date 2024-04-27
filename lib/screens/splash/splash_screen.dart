import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/screens/home_main/home_main.dart';
import 'package:social_media_app/screens/login/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoggedIn = false;
  final Stream<User?> _userState = FirebaseAuth.instance.authStateChanges();

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1500),
        pageBuilder: (context, animation1, animation2) => const HomeMain(),
        transitionsBuilder: (context, animation1, animation2, child) {
          return FadeTransition(
            opacity: animation1,
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1500),
        pageBuilder: (context, animation1, animation2) => const LoginScreen(),
        transitionsBuilder: (context, animation1, animation2, child) {
          return FadeTransition(
            opacity: animation1,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (_isLoggedIn && FirebaseAuth.instance.currentUser != null) {
        _navigateToHome();
      } else {
        _navigateToLogin();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
      stream: _userState,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else if (snapshot.connectionState == ConnectionState.active &&
            snapshot.hasData) {
          //ignore:avoid_print
          print("User Data for authentication --> ${snapshot.data}");
          final user = snapshot.data;
          if (user!.emailVerified) {
            _isLoggedIn = true;
          } else {
            _isLoggedIn = false;
          }
        }
        return _splashScreen(context);
      },
    ));
  }

  Widget _splashScreen(BuildContext context) {
    return Stack(
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
            style: TextStyle(fontFamily: 'Roboto', fontSize: 16.0),
          ),
        ),
      ],
    );
  }
}
