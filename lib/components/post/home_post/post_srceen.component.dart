import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math' as math;

import 'package:social_media_app/utils/config.dart';

class PostComponent extends StatelessWidget {
  PostComponent({
    super.key,
    required this.username,
    this.imageUrlProfile,
    required this.imageUrlPosts,
    required this.contentPost,
    required this.createDatePost,
    required this.postLikes,
    required this.postComments,
    required this.isLiked,
    required this.onLikeToggle,
    required this.onCommentToggle,
    required this.onShareToggle,
    required this.onViewLikes,
    required this.onViewComments,
    required this.onViewProfile,
    this.itemBuilderPopupMenu,
    this.onSelectedPopupMenu,
  });
  final String username;
  final String? imageUrlProfile;
  final List<Widget> imageUrlPosts;
  final String contentPost;
  final String createDatePost;
  final int postLikes;
  final int postComments;
  final bool isLiked;
  final VoidCallback onLikeToggle;
  final VoidCallback onCommentToggle;
  final VoidCallback onShareToggle;
  final VoidCallback onViewLikes;
  final VoidCallback onViewComments;
  final VoidCallback onViewProfile;
  final List<PopupMenuEntry<String>> Function(BuildContext)?
      itemBuilderPopupMenu;
  final void Function(String)? onSelectedPopupMenu;
  final ValueNotifier<int> _currentMedia = ValueNotifier<int>(0);

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
                GestureDetector(
                  onTap: onViewProfile,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CachedNetworkImage(
                          imageUrl: imageUrlProfile ?? imageProfileExample,
                          imageBuilder: (context, imageProvider) {
                            return CircleAvatar(
                              radius: 20,
                              backgroundImage: imageProvider,
                            );
                          },
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Theme.of(context).colorScheme.primary,
                            highlightColor:
                                Theme.of(context).colorScheme.secondary,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  Theme.of(context).colorScheme.background,
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
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
                ),
                if (itemBuilderPopupMenu != null)
                  PopupMenuButton(
                    itemBuilder: itemBuilderPopupMenu!,
                    onSelected: onSelectedPopupMenu,
                  )
              ],
            ),
          ),
          if (imageUrlPosts.isNotEmpty)
            Stack(
              children: [
                CarouselSlider(
                  items: imageUrlPosts,
                  options: CarouselOptions(
                    height: 400.0,
                    viewportFraction: 1,
                    enlargeCenterPage: true,
                    enlargeStrategy: CenterPageEnlargeStrategy.height,
                    enableInfiniteScroll: false,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {
                      _currentMedia.value = index;
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ValueListenableBuilder<int>(
                      valueListenable: _currentMedia,
                      builder: (context, value, child) {
                        if (imageUrlPosts.length > 1) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.6),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                '${value + 1}/${imageUrlPosts.length}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                ),
              ],
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
                  onPressed: onCommentToggle,
                  icon: const Icon(Icons.mode_comment_outlined),
                ),
                Transform.rotate(
                  angle: -45 * math.pi / 180,
                  child: IconButton(
                    onPressed: onShareToggle,
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
                    postComments > 1
                        ? 'View all $postComments comments'
                        : 'View $postComments comment',
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
