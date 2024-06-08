import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/list/list_tile_user.dart';
import 'package:social_media_app/components/loading/loading_flickr.component.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/services/users/user.services.dart';

class ListMessageScreen extends StatefulWidget {
  const ListMessageScreen({super.key});

  @override
  State<ListMessageScreen> createState() => _ListMessageScreenState();
}

class _ListMessageScreenState extends State<ListMessageScreen> {
  final UserServices _userServices = UserServices();
  final _currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _searchController = TextEditingController();
  Users? _user;
  @override
  void initState() {
    super.initState();
    _getUserCurrent();
  }

  void _getUserCurrent() async {
    _user = await _userServices.getUserDetailsByID(_currentUser!.uid);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _user?.username ?? 'Unknown',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: _user != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CupertinoSearchTextField(
                    controller: _searchController,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Messages',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {},
                        child: ListTileComponent(
                          username: _user?.username ?? 'Unknown',
                          imageUrl: _user?.imageProfile,
                          subtitle: _user?.description ?? '',
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : const LoadingFlickrComponent(),
    );
  }
}
