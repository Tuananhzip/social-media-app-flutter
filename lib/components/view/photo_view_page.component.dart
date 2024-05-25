import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:social_media_app/utils/app_colors.dart';

class PhotoViewPageComponent extends StatelessWidget {
  const PhotoViewPageComponent({super.key, required this.imageProvider});
  final ImageProvider imageProvider;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PhotoView(imageProvider: imageProvider),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 42.0, left: 20.0),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.backgroundColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
