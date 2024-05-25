import 'package:flutter/material.dart';

class ListPostComponent extends StatelessWidget {
  const ListPostComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.count(
            padding: const EdgeInsets.only(top: 0),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            crossAxisCount: 3,
            children: List.generate(15, (index) {
              return buildListItemStory(
                context,
                index,
                "https://cdn.vn.alongwalk.info/vn/wp-content/uploads/2023/02/13190852/image-99-hinh-anh-con-bo-sua-cute-che-dang-yeu-dep-me-hon-2023-167626493122484.jpg",
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
