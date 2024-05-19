import 'dart:io';

import 'package:flutter/material.dart';

class DisplayPictureScreen extends StatelessWidget {
  const DisplayPictureScreen({super.key, required this.imagePath});
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(imagePath)),
              fit: BoxFit.cover,
            ),
          )),
    );
  }
}
