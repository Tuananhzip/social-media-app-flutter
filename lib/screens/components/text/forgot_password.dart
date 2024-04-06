import 'package:flutter/material.dart';
import 'package:social_media_app/utils/app_colors.dart';

class ForgotPasswordText extends StatelessWidget {
  const ForgotPasswordText({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Xử lý sự kiện khi được nhấn quên mk
      },
      child: Text(
        "Forgot password?",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.blackColor.withOpacity(0.6),
          fontSize: 14.0,
        ),
      ),
    );
  }
}
