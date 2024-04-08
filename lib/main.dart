import 'package:flutter/material.dart';
import 'package:social_media_app/screens/home/home_main.dart';
import 'package:social_media_app/screens/login/login.dart';
import 'package:social_media_app/screens/register/register_account.dart';
import 'package:social_media_app/screens/splash/splash_screen.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social Media App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home-main': (context) => const HomeMain(),
      },
    );
  }
}
