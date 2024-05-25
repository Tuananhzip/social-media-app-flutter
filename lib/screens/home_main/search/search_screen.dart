import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:social_media_app/components/loading/shimmer_full.component.dart';
import 'package:social_media_app/screens/home_main/search/profile_users_screen.dart';
import 'package:social_media_app/services/users/user.services.dart';
import 'package:social_media_app/utils/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchQueryController = TextEditingController();
  final UserServices _userServices = UserServices();
  String _searchQuery = '';

  Future<void> getUserDetails(String docID) async {
    try {
      final user = await _userServices.getUserDetailsByID(docID);
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => ProfileUsersScreen(
            user: user!,
            uid: docID,
          ),
        ),
      );
    } catch (error) {
      // ignore: avoid_print
      print("getUserDetails ERROR ---> $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: CupertinoSearchTextField(
            controller: _searchQueryController,
            keyboardType: TextInputType.multiline,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        body: buildSearchResult(),
      ),
    );
  }

  Widget buildSearchResult() {
    return StreamBuilder<QuerySnapshot>(
      stream: _userServices.getUsernameStream(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error --->: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.flickr(
              leftDotColor: AppColors.loadingLeftBlue,
              rightDotColor: AppColors.loadingRightRed,
              size: 30.0,
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No results found'));
        }
        final data = snapshot.data!.docs;

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final username = data[index]['username'];
            final imageProfile = data[index]['image_profile'];
            final documentData = data[index];
            return ListTile(
              title: Text('$username [$index]'),
              subtitle: Text(documentData.id),
              contentPadding: const EdgeInsets.all(16.0),
              leading: SizedBox(
                width: 50,
                height: 50,
                child: CachedNetworkImage(
                  imageUrl: imageProfile != null && imageProfile != ''
                      ? imageProfile
                      : "https://theatrepugetsound.org/wp-content/uploads/2023/06/Single-Person-Icon.png",
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    backgroundImage: imageProvider,
                  ),
                  placeholder: (context, url) =>
                      const ShimmerContainerFullComponent(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              onTap: () => getUserDetails(documentData.id),
            );
          },
        );
      },
    );
  }
}
