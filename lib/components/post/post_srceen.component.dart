import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

import 'package:social_media_app/components/loading/overlay_loading.component.dart';

class PostComponent extends StatelessWidget {
  const PostComponent({
    super.key,
    required this.username,
    this.imageUrlProfile,
    required this.imageUrlPosts,
    required this.contentPost,
    required this.createDatePost,
  });
  final String username;
  final String? imageUrlProfile;
  final List<Widget> imageUrlPosts;
  final String contentPost;
  final String createDatePost;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrlProfile ??
                          'https://images.unsplash.com/photo-1713392899774-5f1c261c4a77?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      imageBuilder: (context, imageProvider) {
                        return CircleAvatar(
                          radius: 20,
                          backgroundImage: imageProvider,
                        );
                      },
                      placeholder: (context, url) =>
                          const OverlayLoadingWidget(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        username,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz_rounded),
                )
              ],
            ),
          ),
          if (imageUrlPosts.isNotEmpty)
            CarouselSlider(
              items: imageUrlPosts,
              options: CarouselOptions(
                height: 400.0,
                viewportFraction: 1,
                enlargeCenterPage: true,
                enlargeStrategy: CenterPageEnlargeStrategy.height,
                enableInfiniteScroll: false,
                scrollDirection: Axis.horizontal,
              ),
            ),
          if (contentPost.isNotEmpty || contentPost != '')
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      textAlign: TextAlign.left,
                      contentPost,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  )
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border_rounded),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.mode_comment_outlined),
                ),
                Transform.rotate(
                  angle: -45 * math.pi / 180,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.send_outlined),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '111 likes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'View all 36 comments',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                createDatePost,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          Divider(
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
