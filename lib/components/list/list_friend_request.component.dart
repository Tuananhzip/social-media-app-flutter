import 'package:flutter/material.dart';

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
                child: CircleAvatar(
                  backgroundImage: NetworkImage(listImages.last ??
                      'https://theatrepugetsound.org/wp-content/uploads/2023/06/Single-Person-Icon.png'),
                ),
              ),
            if (listImages.isNotEmpty)
              Positioned(
                left: 20.0,
                top: 10.0,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(listImages.first ??
                      'https://theatrepugetsound.org/wp-content/uploads/2023/06/Single-Person-Icon.png'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
