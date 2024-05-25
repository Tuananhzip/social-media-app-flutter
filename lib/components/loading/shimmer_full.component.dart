import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerContainerFullComponent extends StatelessWidget {
  const ShimmerContainerFullComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.primary,
      highlightColor: Theme.of(context).colorScheme.secondary,
      child: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
      ),
    );
  }
}
