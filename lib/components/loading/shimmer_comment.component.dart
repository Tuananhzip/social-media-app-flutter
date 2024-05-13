import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCommentComponent extends StatelessWidget {
  const ShimmerCommentComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.primary,
      highlightColor: Theme.of(context).colorScheme.secondary,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.background,
        ),
        title: Container(
          height: 15,
          color: Theme.of(context).colorScheme.background,
        ),
        subtitle: Container(
          height: 10,
          color: Theme.of(context).colorScheme.background,
        ),
      ),
    );
  }
}
