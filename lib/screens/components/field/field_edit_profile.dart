import 'package:flutter/material.dart';
import 'package:social_media_app/utils/app_colors.dart';

class FieldEditProfile extends StatelessWidget {
  const FieldEditProfile(
      {super.key,
      required this.controller,
      this.validation,
      this.textInputType});

  final TextEditingController controller;
  final String? Function(String?)? validation;
  final TextInputType? textInputType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validation,
      keyboardType: textInputType,
      cursorColor: AppColors.blackColor,
    );
  }
}
