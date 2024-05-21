import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPostComponent extends StatelessWidget {
  const ShimmerPostComponent({super.key});

  Widget buildContainer(
      double widthFactor, double height, double margin, BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * widthFactor,
      height: height,
      color: Theme.of(context).colorScheme.background,
      margin: EdgeInsets.symmetric(horizontal: margin),
    );
  }

  Widget buildPadding() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.primary,
      highlightColor: Theme.of(context).colorScheme.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                ),
                buildContainer(0.7, 25.0, 16, context),
              ],
            ),
          ),
          buildContainer(1, 400.0, 0, context),
          buildPadding(),
          buildContainer(0.9, 22.0, 16.0, context),
          buildPadding(),
          buildContainer(0.9, 22.0, 16.0, context),
          buildPadding(),
          buildContainer(0.75, 20.0, 16.0, context),
          buildPadding(),
          buildContainer(0.25, 15.0, 16.0, context),
          buildPadding(),
          buildContainer(0.45, 15.0, 16.0, context),
          buildPadding(),
          buildContainer(0.65, 15.0, 16.0, context),
          Divider(
            color: Colors.grey[300],
            thickness: 1.0,
          ),
        ],
      ),
    );
  }
}
