import 'package:flutter/material.dart';
import 'package:social_media_app/screens/components/story/story_screen.dart';
import 'package:social_media_app/utils/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          title: const Text("Minthwhite",
              style: TextStyle(
                  fontFamily: "Italianno",
                  fontSize: 42.0,
                  fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
                onPressed: () => {}, icon: const Icon(Icons.add_box_outlined)),
            IconButton(
                onPressed: () => {},
                icon: const Icon(Icons.notifications_none_outlined))
          ],
        ),
      ],
      body: Column(
        children: [
          SizedBox(
            height: 115,
            child: ListView.builder(
              itemCount: 15,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                bool statusStory = false;
                String userName = "Trần Ngọc Khánhsdsada";
                List<String> nameParts = userName.split(' ');
                String lastName =
                    nameParts.isNotEmpty ? nameParts.last : userName;
                String lastNameOverflow = lastName.length > 8
                    ? '${lastName.substring(0, 6)}...'
                    : lastName;
                String imageUser =
                    "https://letsenhance.io/static/8f5e523ee6b2479e26ecc91b9c25261e/1015f/MainAfter.jpg";
                return buildListItemStory(
                    context,
                    index,
                    imageUser,
                    lastNameOverflow,
                    statusStory); // username, status story video (User and VideoStories)
              },
            ),
          ),
          Divider(
            color: AppColors.blackColor.withOpacity(0.2),
          ),
        ],
      ),
    ));
  }

  Widget buildListItemStory(BuildContext context, int index, String imageUser,
      String lastNameOverflow, bool statusStory) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StoryScreen(userName: lastNameOverflow)));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: statusStory == true ? Colors.grey : Colors.blue,
                  width: 4.0,
                ),
                image: DecorationImage(
                  image: NetworkImage(imageUser),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(
              lastNameOverflow,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            )
          ],
        ),
      ),
    );
  }
}
