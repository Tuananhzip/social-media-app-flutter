import 'dart:io';

import 'package:flutter/material.dart';

class CreatePostImageScreenComponent extends StatelessWidget {
  const CreatePostImageScreenComponent({super.key, required this.file});
  final File file;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400.0,
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          file,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
