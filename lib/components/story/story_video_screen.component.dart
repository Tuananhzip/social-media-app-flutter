import 'package:flutter/material.dart';

class StoryVideoComponentScreen extends StatefulWidget {
  const StoryVideoComponentScreen({super.key, required this.storyId});
  final String storyId;

  @override
  State<StoryVideoComponentScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<StoryVideoComponentScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
