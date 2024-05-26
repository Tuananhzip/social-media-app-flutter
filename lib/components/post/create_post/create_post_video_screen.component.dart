import 'dart:io';

import 'package:flutter/material.dart';

class CreatePostVideoScreenComponent extends StatelessWidget {
  const CreatePostVideoScreenComponent(
      {super.key, required this.thumbnailVideoFile});
  final File thumbnailVideoFile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          thumbnailVideoFile,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
