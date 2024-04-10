import 'package:flutter/material.dart';
import 'package:social_media_app/utils/app_colors.dart';

class OutlineButtonLogin extends StatelessWidget {
  const OutlineButtonLogin({
    super.key,
    this.onTap,
    required this.text,
  });
  final void Function()? onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.transparent,
            border:
                Border.all(width: 1.0, color: AppColors.blueButtonAccentColor)),
        child: Text(
          text,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.blueButtonAccentColor,
              fontSize: 16.0),
        ),
      ),
    );
  }
}
