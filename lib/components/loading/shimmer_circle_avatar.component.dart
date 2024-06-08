import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCircleAvatarComponent extends StatelessWidget {
  const ShimmerCircleAvatarComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.primary,
      highlightColor: Theme.of(context).colorScheme.secondary,
      child: CircleAvatar(
        radius: 35.0,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
    );
  }
}
