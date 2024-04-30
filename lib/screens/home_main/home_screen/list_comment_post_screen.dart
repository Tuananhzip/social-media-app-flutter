import 'package:flutter/material.dart';

class ListCommentsScreen extends StatefulWidget {
  const ListCommentsScreen({super.key, required this.postId});
  final String postId;

  @override
  State<ListCommentsScreen> createState() => _ListCommentsScreenState();
}

class _ListCommentsScreenState extends State<ListCommentsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
