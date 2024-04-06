import 'package:flutter/material.dart';
import 'package:social_media_app/utils/app_colors.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        backgroundColor: AppColors.blueColor,
      ),
    );
  }
}
