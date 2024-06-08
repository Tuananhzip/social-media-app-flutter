import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_media_app/screens/home_main/create_post/create_post_screen.dart';
import 'package:social_media_app/screens/home_main/home_screen/home_screen.dart';
import 'package:social_media_app/screens/home_main/list_story/list_story_screen.dart';
import 'package:social_media_app/screens/home_main/profile/profile_screen.dart';
import 'package:social_media_app/screens/home_main/search/search_screen.dart';
import 'package:social_media_app/services/users/user.services.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/my_enum.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({super.key, required this.fragment});
  final Fragments fragment;

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  late Fragments _currentFragment;
  final UserServices _userServices = UserServices();
  String? _imageUser;

  void _onItemTapped(int index) {
    setState(() {
      _currentFragment = Fragments.values[index];
    });
  }

  @override
  void initState() {
    super.initState();
    _currentFragment = widget.fragment;
    _getProfileImageUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getProfileImageUser() {
    _userServices.getProfileImageByCurrentUser().then(
          (imageProfile) => setState(
            () {
              _imageUser = imageProfile;
            },
          ),
        );
  }

  static const List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
    CreatePostScreen(),
    ListStoryScreen(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        bool shouldPop = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Are you sure you want to leave this screen?'),
              actions: [
                TextButton(
                  child: Text(
                    'No',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(
                    'Yes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        );
        if (shouldPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: _screens[_currentFragment.index],
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
          items: [
            const BottomNavigationBarItem(
                icon: Icon(
                  Icons.home_outlined,
                ),
                label: "Home",
                activeIcon: Icon(Icons.home)),
            const BottomNavigationBarItem(
                icon: Icon(
                  Icons.screen_search_desktop_outlined,
                ),
                label: "Search",
                activeIcon: Icon(Icons.screen_search_desktop_rounded)),
            const BottomNavigationBarItem(
                icon: Icon(
                  Icons.add_box_outlined,
                ),
                label: "Post",
                activeIcon: Icon(Icons.add_box)),
            const BottomNavigationBarItem(
                icon: Icon(
                  Icons.video_library_outlined,
                ),
                label: "Stories",
                activeIcon: Icon(Icons.video_library)),
            BottomNavigationBarItem(
              icon: _imageUser != null
                  ? CircleAvatar(
                      radius: 12.0,
                      backgroundImage: CachedNetworkImageProvider(_imageUser!),
                    )
                  : const Icon(Icons.person),
              label: "Personal",
              activeIcon: _imageUser != null
                  ? Container(
                      width: 24.0,
                      height: 24.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.background ==
                                  AppColors.backgroundColor
                              ? AppColors.blackColor
                              : AppColors.backgroundColor,
                          width: 2.0,
                        ),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(_imageUser!),
                          fit: BoxFit.cover,
                        ),
                        shape: BoxShape.circle,
                      ),
                    )
                  : const Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }
}
