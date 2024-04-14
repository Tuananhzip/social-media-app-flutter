import 'package:flutter/material.dart';

class StoryScreen extends StatelessWidget {
  final String userName;
  const StoryScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Theme.of(context).colorScheme.background,
      child: Text("Video story của $userName"),
    );
  }
}
