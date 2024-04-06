import 'package:flutter/material.dart';
import 'package:social_media_app/utils/app_colors.dart';

class ButtonLogin extends StatelessWidget {
  const ButtonLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {
        // sự kiện khi login button
      },
      child: Container(
        alignment: Alignment.center,
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: AppColors.blueButtonColor),
        child: const Text(
          "Login",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
              fontSize: 16.0),
        ),
      ),
    );
  }
}
