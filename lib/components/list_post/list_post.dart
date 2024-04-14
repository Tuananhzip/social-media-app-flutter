import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ListPost extends StatelessWidget {
  const ListPost({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.count(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            crossAxisCount: 3, // Số lượng cột trong GridView
            children: List.generate(15, (index) {
              return buildListItemStory(
                context,
                index,
                "https://letsenhance.io/static/8f5e523ee6b2479e26ecc91b9c25261e/1015f/MainAfter.jpg",
              );
            }),
          ),
        )
      ],
    );
  }

  Widget buildListItemStory(
    BuildContext context,
    int index,
    String imageUser,
  ) {
    return GestureDetector(
      onTap: () {
        // Xử lý khi người dùng nhấn vào hình ảnh
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              width: 0.2, color: Theme.of(context).colorScheme.background),
          image: DecorationImage(
            image: NetworkImage(imageUser),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
