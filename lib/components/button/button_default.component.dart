import 'package:flutter/material.dart';

class ButtonDefaultComponent extends StatelessWidget {
  const ButtonDefaultComponent(
      {super.key,
      this.text,
      required this.onTap,
      this.colorBackground,
      this.colorText,
      this.icon});
  final String? text;
  final Color? colorBackground;
  final Color? colorText;
  final void Function()? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: colorBackground),
        child: icon != null
            ? Icon(
                icon,
              )
            : Text(
                text ?? '',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorText,
                    fontSize: 16.0),
              ),
      ),
    );
  }
}
