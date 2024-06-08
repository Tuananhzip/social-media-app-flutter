import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerTileComponent extends StatelessWidget {
  const ShimmerTileComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.primary,
      highlightColor: Theme.of(context).colorScheme.secondary,
      child: ListTile(
        title: Container(
          height: 12,
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
