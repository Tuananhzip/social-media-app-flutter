import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/utils/collection_names.dart';
import 'package:social_media_app/utils/field_names.dart';

class FeaturedStoryServices {
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _featuredStoriesCollection = FirebaseFirestore.instance
      .collection(FirestoreCollectionNames.featuredStories);
  Future<List<DocumentSnapshot>> getFeaturedStoriesForCurrentUser() async {
    try {
      final featuredStories = await _featuredStoriesCollection
          .where(DocumentFieldNames.uid, isEqualTo: _currentUser!.uid)
          .get();
      return featuredStories.docs;
    } catch (e) {
      // ignore: avoid_print
      print('getFeaturedStoriesForCurrentUser ERROR ---> $e');
      return [];
    }
  }
}
