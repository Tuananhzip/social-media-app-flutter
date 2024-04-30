import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
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
    required this.postLikes,
    required this.isLiked,
    required this.onLikeToggle,
    required this.onViewLikes,
    required this.onViewComments,
  });
  final String username;
  final String? imageUrlProfile;
  final List<Widget> imageUrlPosts;
  final String contentPost;
  final String createDatePost;
  final int postLikes;
  final bool isLiked;
  final VoidCallback onLikeToggle;
  final VoidCallback onViewLikes;
  final VoidCallback onViewComments;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                          'https://theatrepugetsound.org/wp-content/uploads/2023/06/Single-Person-Icon.png',
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
                  onPressed: onLikeToggle,
                  icon: isLiked
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      : const Icon(Icons.favorite_border),
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
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onViewLikes,
                  child: Text(
                    postLikes > 1 ? '$postLikes likes' : '$postLikes like',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                GestureDetector(
                  onTap: onViewComments,
                  child: Text(
                    'View all 36 comments',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text(
                  createDatePost,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Divider(
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
