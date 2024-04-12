import 'package:flutter/material.dart';

class ListVideoScreen extends StatelessWidget {
  const ListVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
    );
  }
}
