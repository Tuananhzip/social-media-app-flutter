import 'package:flutter/material.dart';
import 'package:social_media_app/screens/home_main/create_post/create_post_screen.dart';
import 'package:social_media_app/screens/home_main/home_screen/home_screen.dart';
import 'package:social_media_app/screens/home_main/list_video/list_video_screen.dart';
import 'package:social_media_app/screens/home_main/profile/profile_screen.dart';
import 'package:social_media_app/screens/home_main/search/search_screen.dart';
import 'package:social_media_app/utils/my_enum.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({super.key});

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  Fragments currentFragment = Fragments.homeScreen;

  void onItemTapped(int index) {
    setState(() {
      currentFragment = indexToFragment(index);
    });
  }

  Fragments indexToFragment(int index) {
    switch (index) {
      case 0:
        return Fragments.homeScreen;
      case 1:
        return Fragments.searchScreen;
      case 2:
        return Fragments.createPostScreen;
      case 3:
        return Fragments.listVideoScreen;
      case 4:
        return Fragments.profileScreen;
      default:
        return Fragments.homeScreen;
    }
  }

  int fragmentToIndex(Fragments fragment) {
    return fragment.index;
  }

  final List<Widget> screens = [
    const HomeScreen(),
    const SearchScreen(),
    const CreatePostScreen(),
    const ListVideoScreen(),
    const ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: fragmentToIndex(currentFragment),
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: fragmentToIndex(currentFragment),
        onTap: onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
              ),
              label: "Home",
              activeIcon: Icon(Icons.home)),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.screen_search_desktop_outlined,
              ),
              label: "Search",
              activeIcon: Icon(Icons.screen_search_desktop_rounded)),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.add_box_outlined,
              ),
              label: "Post",
              activeIcon: Icon(Icons.add_box)),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.video_library_outlined,
              ),
              label: "Videos",
              activeIcon: Icon(Icons.video_library)),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person_outline,
              ),
              label: "Personal",
              activeIcon: Icon(Icons.person)),
        ],
      ),
    );
  }
}
