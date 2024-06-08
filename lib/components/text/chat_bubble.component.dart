import 'package:flutter/material.dart';
import 'package:social_media_app/utils/app_colors.dart';

class ChatBubbleComponent extends StatelessWidget {
  const ChatBubbleComponent(
      {super.key, required this.message, required this.isSender});
  final String message;
  final bool isSender;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: isSender
            ? AppColors.blueColor
            : Theme.of(context).colorScheme.primary,
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 16.0),
      ),
    );
  }
}
