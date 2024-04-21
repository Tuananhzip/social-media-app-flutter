import 'package:flutter/material.dart';
import 'package:social_media_app/utils/app_colors.dart';

class FieldEditProfileComponent extends StatelessWidget {
  const FieldEditProfileComponent(
      {super.key,
      required this.controller,
      this.validation,
      this.textInputType,
      this.readOnly,
      this.onTap});

  final TextEditingController controller;
  final String? Function(String?)? validation;
  final TextInputType? textInputType;
  final bool? readOnly;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validation,
      keyboardType: textInputType,
      cursorColor: AppColors.blackColor,
      decoration: const InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.blackColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.blackColor),
        ),
        errorMaxLines: 3,
      ),
      readOnly: readOnly ?? false,
      onTap: onTap,
    );
  }
}
