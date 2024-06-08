import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media_app/utils/config.dart';

class ListTileComponent extends StatelessWidget {
  const ListTileComponent({
    super.key,
    required this.username,
    this.imageUrl,
    required this.subtitle,
    this.onTap,
  });
  final String username;
  final String? imageUrl;
  final String subtitle;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(username),
      subtitle: Text(subtitle),
      leading: CachedNetworkImage(
        imageUrl: imageUrl ?? imageProfileExample,
        imageBuilder: (context, imageProvider) {
          return CircleAvatar(
            backgroundImage: imageProvider,
          );
        },
        placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.primary,
            highlightColor: Theme.of(context).colorScheme.secondary,
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.background,
            )),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
      onTap: onTap,
    );
  }
}
