import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/loading/shimmer_full.component.dart';

class ListTileFriendRequestComponent extends StatelessWidget {
  const ListTileFriendRequestComponent({
    super.key,
    this.subtitle,
    required this.listImages,
    this.listTrailing,
    this.title,
  });
  final String? title;
  final String? subtitle;
  final List<String?> listImages;
  final List<Widget>? listTrailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title ?? '',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Wrap(
        spacing: 12, // space between two icons
        children: listTrailing ?? [],
      ),
      subtitle: Text(subtitle ?? ''),
      leading: SizedBox(
        width: 70,
        height: 70,
        child: Stack(
          children: [
            if (listImages.length > 1)
              Positioned(
                left: 0,
                child: CachedNetworkImage(
                  imageUrl: listImages.last ??
                      'https://theatrepugetsound.org/wp-content/uploads/2023/06/Single-Person-Icon.png',
                  imageBuilder: (context, imageProvider) {
                    return CircleAvatar(
                      backgroundImage: imageProvider,
                    );
                  },
                  placeholder: (context, url) =>
                      const ShimmerContainerFullComponent(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            if (listImages.isNotEmpty)
              Positioned(
                left: 20.0,
                top: 10.0,
                child: CachedNetworkImage(
                  imageUrl: listImages.first ??
                      'https://theatrepugetsound.org/wp-content/uploads/2023/06/Single-Person-Icon.png',
                  imageBuilder: (context, imageProvider) {
                    return CircleAvatar(
                      backgroundImage: imageProvider,
                    );
                  },
                  placeholder: (context, url) =>
                      const ShimmerContainerFullComponent(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
