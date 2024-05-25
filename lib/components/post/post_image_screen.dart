import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media_app/components/view/photo_view_page.component.dart';

class PostImageScreenComponent extends StatelessWidget {
  const PostImageScreenComponent({super.key, required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) {
          return GestureDetector(
            onDoubleTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PhotoViewPageComponent(imageProvider: imageProvider),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
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
