import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ImageScreenComponent extends StatefulWidget {
  const ImageScreenComponent({super.key, required this.url});
  final String url;

  @override
  State<ImageScreenComponent> createState() => _ImageScreenComponentState();
}

class _ImageScreenComponentState extends State<ImageScreenComponent> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: CachedNetworkImage(
        imageUrl: widget.url,
        imageBuilder: (context, imageProvider) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.primary,
          highlightColor: Theme.of(context).colorScheme.secondary,
          child: Container(
            color: Theme.of(context).colorScheme.background,
          ),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}
