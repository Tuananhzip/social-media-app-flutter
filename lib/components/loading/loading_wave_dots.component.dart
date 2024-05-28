import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:social_media_app/utils/app_colors.dart';

class LoadingWaveDotsComponent extends StatelessWidget {
  const LoadingWaveDotsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.waveDots(
        color: AppColors.backgroundColor,
        size: 30.0,
      ),
    );
  }
}
