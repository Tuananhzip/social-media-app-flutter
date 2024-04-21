import 'package:flutter/material.dart';
import 'package:social_media_app/utils/app_colors.dart';

class InputFieldDefaultComponent extends StatelessWidget {
  const InputFieldDefaultComponent({
    super.key,
    required this.controller,
    required this.text,
    required this.textInputType,
    required this.obscure,
    this.prefixIcon,
    this.suffixIcon,
    this.onPressSuffixIcon,
    this.isValidation,
    this.onTap,
  });

  final TextEditingController controller;
  final String text;
  final TextInputType textInputType;
  final bool obscure;
  final Icon? prefixIcon;
  final Icon? suffixIcon;
  final void Function()? onPressSuffixIcon;
  final String? Function(String?)? isValidation;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlign: TextAlign.start,
      controller: controller,
      style: const TextStyle(color: AppColors.blackColor),
      cursorColor: AppColors.blackColor,
      keyboardType: textInputType,
      obscureText: obscure,
      decoration: InputDecoration(
        fillColor: AppColors.backgroundColor,
        filled: true,
        prefixIcon: prefixIcon,
        prefixIconColor: AppColors.blackColor,
        labelText: text,
        errorStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 14.0,
        ),
        errorMaxLines: 3,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(
            color: AppColors.blackColor,
          ),
        ),
        labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: AppColors.blackColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        suffixIcon: IconButton(
          icon: suffixIcon ?? const Icon(null),
          onPressed: onPressSuffixIcon,
        ),
        suffixIconColor: AppColors.blackColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 5.0, vertical: 15.0),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: isValidation,
      onTap: onTap,
    );
  }
}
