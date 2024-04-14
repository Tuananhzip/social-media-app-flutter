import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:social_media_app/serviecs/Users/user_services.dart';
import 'package:social_media_app/utils/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchQueryController = TextEditingController();
  final UserServices userServices = UserServices();
  String searchQuery = '';
  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: CupertinoSearchTextField(
            controller: searchQueryController,
            keyboardType: TextInputType.multiline,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
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
      stream: userServices.getUsernameStream(searchQuery),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error --->: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No results found'));
        }
        final data = snapshot.data!.docs;
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final username = data[index]['username'];
            final imageProfile = data[index]['imageProfile'];
            return ListTile(
              title: Text(username),
              tileColor: AppColors.blueColor,
              contentPadding: const EdgeInsets.all(16.0),
              leading: CircleAvatar(
                backgroundImage: imageProfile != null && imageProfile != ''
                    ? NetworkImage(imageProfile)
                    : const NetworkImage(
                        "https://theatrepugetsound.org/wp-content/uploads/2023/06/Single-Person-Icon.png"),
              ),
            );
          },
        );
      },
    );
  }
}
