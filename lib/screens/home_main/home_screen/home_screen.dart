import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_app/components/loading/overlay_loading.component.dart';
import 'package:social_media_app/components/post/post_srceen.component.dart';
import 'package:social_media_app/components/story/story_screen.component.dart';
import 'package:social_media_app/models/posts.dart';
import 'package:social_media_app/screens/home_main/home_screen/notifications_screen/notifications_screen.dart';
import 'package:social_media_app/services/posts/post.services.dart';
import 'package:social_media_app/theme/theme_provider.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController scrollController = ScrollController();
  final PostService postService = PostService();
  List<Posts> posts = [];
  late bool isDarkMode = false;
  bool isLoading = false;
  late DocumentSnapshot? lastVisible;
  List<List<Widget>> listOfListUrlPosts = [];

  @override
  initState() {
    super.initState();
    initDarkMode();
    loadPosts();
    scrollController.addListener(scrollListen);
  }

  @override
  void dispose() {
    super.dispose();

    scrollController.removeListener(scrollListen);
    scrollController.dispose();
    posts.clear();
    listOfListUrlPosts.clear();
  }

  void scrollListen() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (!isLoading) {
        isLoading = true;
        loadMorePosts().then((_) => isLoading = false);
      }
    }
  }

  Future<void> loadPosts() async {
    List<DocumentSnapshot> postData = await postService.loadPostsLazy();
    if (postData.isNotEmpty) {
      lastVisible = postData[postData.length - 1];
      List<Posts> postDummy = postData
          .map((data) => Posts.formMap(data.data() as Map<String, dynamic>))
          .toList();
      setState(() {
        posts.clear();
        listOfListUrlPosts.clear();
        posts.addAll(postDummy);
      });
      checkMediaList(posts);
    }
  }

  Future<void> loadMorePosts() async {
    List<DocumentSnapshot> morePosts =
        await postService.loadPostsLazy(lastVisible: lastVisible);
    if (morePosts.isNotEmpty) {
      lastVisible = morePosts[morePosts.length - 1];
      List<Posts> postDummy = morePosts
          .map((data) => Posts.formMap(data.data() as Map<String, dynamic>))
          .toList();
      setState(() {
        posts.addAll(postDummy);
      });
      checkMediaList(postDummy);
    }
  }

  void checkMediaList(List<Posts> postsDummy) {
    if (postsDummy.isNotEmpty) {
      for (var post in postsDummy) {
        List<Widget> listDummy = [];
        if (post.mediaLink != null || post.mediaLink!.isNotEmpty) {
          post.mediaLink?.forEach((url) async {
            final listPart = url.split('.');
            final lastPart = listPart.last.toLowerCase().split('?');
            String extensions = lastPart.first;
            if (extensions == 'jpg' ||
                extensions == 'png' ||
                extensions == 'jpeg') {
              listDummy.add(buildImage(url));
            } else if (extensions == 'mp4') {
              VideoPlayerController? videoPlayerController;

              videoPlayerController =
                  VideoPlayerController.networkUrl(Uri.parse(url));
              await videoPlayerController.initialize().then((value) {
                setState(() {
                  listDummy.add(buildVideo(videoPlayerController!));
                });
              });
            } else {
              listDummy.add(Container());
            }
          });
        }
        setState(() {
          listOfListUrlPosts.addAll([listDummy]);
        });
      }
    }
  }

  Future<void> initDarkMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode")!;
    });
  }

  Future<void> toggleChangeTheme(context) async {
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
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: const Text(
                "Minthwhite",
                style: TextStyle(
                  fontFamily: "Italianno",
                  fontSize: 42.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                  onPressed: () {},
                  icon: const Icon(Icons.add_box_outlined),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications_none_outlined),
                ),
              ],
              floating: true,
              snap: true,
            ),
          ];
        },
        body: Column(
          children: [
            // SizedBox(
            //   height: 115,
            //   child: ListView.builder(
            //     itemCount: 4,
            //     scrollDirection: Axis.horizontal,
            //     itemBuilder: (context, index) {
            //       bool statusStory = false;
            //       String userName = "Trần Ngọc Khánhsdsada";
            //       List<String> nameParts = userName.split(' ');
            //       String lastName =
            //           nameParts.isNotEmpty ? nameParts.last : userName;
            //       String lastNameOverflow = lastName.length > 8
            //           ? '${lastName.substring(0, 6)}...'
            //           : lastName;
            //       String imageUser =
            //           "https://cdn.vn.alongwalk.info/vn/wp-content/uploads/2023/02/13190852/image-99-hinh-anh-con-bo-sua-cute-che-dang-yeu-dep-me-hon-2023-167626493122484.jpg";
            //       return buildListItemStory(
            //         context,
            //         index,
            //         imageUser,
            //         lastNameOverflow,
            //         statusStory,
            //       ); // username, status story video (User and VideoStories)
            //     },
            //   ),
            // ),
            Expanded(
              child: posts.isNotEmpty
                  ? RefreshIndicator(
                      onRefresh: loadPosts,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.vertical,
                        controller: scrollController,
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return PostComponent(
                            username: '${posts[index].uid!}-(${index + 1})',
                            createDatePost:
                                posts[index].postCreatedDate.toString(),
                            contentPost: posts[index].postText ?? '',
                            imageUrlPosts: listOfListUrlPosts[index],
                          );
                        },
                      ),
                    )
                  : const OverlayLoadingWidget(),
            ),
          ],
        ),
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
            builder: (context) => StoryComponent(userName: lastNameOverflow),
          ),
        );
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

  Widget buildImage(String url) => SizedBox(
        width: MediaQuery.of(context).size.width,
        child: CachedNetworkImage(
          imageUrl: url,
          imageBuilder: (context, imageProvider) {
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
          placeholder: (context, url) => const OverlayLoadingWidget(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      );
  Widget buildVideo(VideoPlayerController videoController) => SizedBox(
        width: MediaQuery.of(context).size.width,
        child: videoController.value.isInitialized
            ? AspectRatio(
                aspectRatio: videoController.value.aspectRatio,
                child: VideoPlayer(videoController),
              )
            : const SizedBox(),
      );
}
