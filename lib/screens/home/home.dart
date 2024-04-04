import 'package:flutter/material.dart';
import 'package:social_media_app/utils/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Minthwhite",
          style: TextStyle(fontFamily: "Italianno", fontSize: 40.0),
        ),
        shadowColor: AppColors.greyColor,
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
              onPressed: () => {}, icon: const Icon(Icons.add_box_outlined)),
          IconButton(
              onPressed: () => {},
              icon: const Icon(Icons.notifications_none_outlined))
        ],
      ),
    );
  }
}
