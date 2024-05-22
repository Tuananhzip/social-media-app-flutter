import 'package:flutter/material.dart';
import 'package:social_media_app/screens/home_main/create_post/create_post_screen.dart';
import 'package:social_media_app/screens/home_main/home_screen/home_screen.dart';
import 'package:social_media_app/screens/home_main/list_story/list_story_screen.dart';
import 'package:social_media_app/screens/home_main/profile/profile_screen.dart';
import 'package:social_media_app/screens/home_main/search/search_screen.dart';
import 'package:social_media_app/utils/my_enum.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({super.key});

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  Fragments _currentFragment = Fragments.homeScreen;

  void _onItemTapped(int index) {
    setState(() {
      _currentFragment = Fragments.values[index];
    });
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const CreatePostScreen(),
    const ListStoryScreen(),
    const ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentFragment.index,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentFragment.index,
        onTap: _onItemTapped,
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
              label: "Stories",
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
