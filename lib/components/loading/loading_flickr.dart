import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:social_media_app/utils/app_colors.dart';

class LoadingFlickrComponent extends StatelessWidget {
  const LoadingFlickrComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.flickr(
        leftDotColor: AppColors.loadingLeftBlue,
        rightDotColor: AppColors.loadingRightRed,
        size: 30.0,
      ),
    );
  }
}
