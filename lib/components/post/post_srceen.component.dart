import 'package:flutter/material.dart';
import 'dart:math' as math;

class PostComponent extends StatelessWidget {
  const PostComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1713392899774-5f1c261c4a77?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Your name',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_horiz_rounded))
              ],
            ),
          ),
          FittedBox(
            child: Image.network(
              fit: BoxFit.fill,
              width: MediaQuery.of(context).size.width,
              height: 400.0,
              'https://plus.unsplash.com/premium_photo-1664648184162-2a446ac405e2?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '111 likes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Row(
                        children: [
                          Text(
                            'Your name',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(
                            width: 16.0,
                          ),
                          Text(
                            'Content of post',
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
                        ],
                      ),
                      Text(
                        'View all 36 comments',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '22 hours ago',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
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
