import 'package:flutter/material.dart';
import 'package:social_media_app/utils/app_colors.dart';

class InputFieldLogin extends StatelessWidget {
  const InputFieldLogin({
    super.key,
    required this.controller,
    required this.text,
    required this.textInputType,
    required this.obscure,
    required this.prefixIcon,
    this.suffixIcon,
    this.onPressSuffixIcon,
  });

  final TextEditingController controller;
  final String text;
  final TextInputType textInputType;
  final bool obscure;
  final Icon prefixIcon;
  final Icon? suffixIcon;
  final void Function()? onPressSuffixIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55.0,
      padding: const EdgeInsets.only(top: 3.0, left: 15),
      decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withOpacity(0.2),
              blurRadius: 10,
            )
          ]),
      child: TextFormField(
        controller: controller,
        keyboardType: textInputType,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          labelText: text,
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: suffixIcon ?? const Icon(null),
            onPressed: onPressSuffixIcon,
          ),
          contentPadding: const EdgeInsets.all(0),
        ),
      ),
    );
  }
}
