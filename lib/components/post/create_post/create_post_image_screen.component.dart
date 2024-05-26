import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class CreatePostImageScreenComponent extends StatelessWidget {
  const CreatePostImageScreenComponent({super.key, required this.file});
  final File file;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: PhotoView(
          imageProvider: FileImage(file),
          initialScale: PhotoViewComputedScale.covered,
        ),
      ),
    );
  }
}
