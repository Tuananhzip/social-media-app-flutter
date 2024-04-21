import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_app/components/post/post_srceen.component.dart';
import 'package:social_media_app/components/story/story_screen.component.dart';
import 'package:social_media_app/screens/home/home_screen/notifications_screen.dart';
import 'package:social_media_app/theme/theme_provider.dart';
import 'package:social_media_app/utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool isDarkMode = false;
  @override
  initState() {
    super.initState();
    initDarkMode();
  }

  Future<void> initDarkMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode")!;
    });
  }

  toggleChangeTheme(context) async {
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text("Minthwhite",
                style: TextStyle(
                    fontFamily: "Italianno",
                    fontSize: 42.0,
                    fontWeight: FontWeight.bold)),
            actions: [
              Switch(
                value: isDarkMode,
                onChanged: (value) => toggleChangeTheme(context),
                inactiveThumbImage: const AssetImage('assets/images/sun.png'),
                activeThumbImage: const AssetImage('assets/images/moon.png'),
                inactiveThumbColor: AppColors.backgroundColor,
                activeColor: AppColors.grayAccentColor,
                inactiveTrackColor: AppColors.blueColor,
              ),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.add_box_outlined)),
              IconButton(
                onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  ),
                },
                icon: const Icon(Icons.notifications_none_outlined),
              ),
            ],
            floating: true,
            snap: true,
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 115,
              child: ListView.builder(
                itemCount: 4,
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
                      "https://cdn.vn.alongwalk.info/vn/wp-content/uploads/2023/02/13190852/image-99-hinh-anh-con-bo-sua-cute-che-dang-yeu-dep-me-hon-2023-167626493122484.jpg";
                  return buildListItemStory(
                      context,
                      index,
                      imageUser,
                      lastNameOverflow,
                      statusStory); // username, status story video (User and VideoStories)
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return const PostComponent();
              },
              childCount: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListItemStory(BuildContext context, int index, String imageUser,
      String lastNameOverflow, bool statusStory) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    StoryComponent(userName: lastNameOverflow)));
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
