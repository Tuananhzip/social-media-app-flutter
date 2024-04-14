import 'package:flutter/material.dart';
import 'package:social_media_app/utils/app_colors.dart';

class OverlayLoadingWidget extends StatelessWidget {
  const OverlayLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.blueColor,
      ),
    );
  }
}
