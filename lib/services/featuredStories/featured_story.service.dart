import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/models/featured_story.dart';
import 'package:social_media_app/models/featured_story_detail.dart';
import 'package:social_media_app/services/stories/story.service.dart';
import 'package:social_media_app/utils/collection_names.dart';
import 'package:social_media_app/utils/field_names.dart';

class FeaturedStoryServices {
  final _currentUser = FirebaseAuth.instance.currentUser;
  final StoryServices _storyServices = StoryServices();
  final _featuredStoriesDetailCollection = FirebaseFirestore.instance
      .collection(FirestoreCollectionNames.featuredStoriesDetail);
  final _featuredStoriesCollection = FirebaseFirestore.instance
      .collection(FirestoreCollectionNames.featuredStories);
  Future<List<DocumentSnapshot>> getFeaturedStoriesByUserId(String uid) async {
    try {
      final featuredStories = await _featuredStoriesCollection
          .where(DocumentFieldNames.uid, isEqualTo: uid)
          .get();
      return featuredStories.docs;
    } catch (e) {
      // ignore: avoid_print
      print('getFeaturedStoriesForCurrentUser ERROR ---> $e');
      return [];
    }
  }

  Future<void> addFeaturedStory(
    String featuredStoryDescription,
    String imageUrl,
    List<String> storyIds,
  ) async {
    try {
      final FeaturedStory featuredStory = FeaturedStory(
        uid: _currentUser!.uid,
        featuredStoryDescription: featuredStoryDescription,
        imageUrl: imageUrl,
      );
      final featuredStoryAdded =
          await _featuredStoriesCollection.add(featuredStory.asMap());
      if (featuredStoryAdded.id.isNotEmpty) {
        await _addFeaturedStoryDetail(featuredStoryAdded.id, storyIds);
      }
    } catch (e) {
      // ignore: avoid_print
      print('addFeaturedStory ERROR ---> $e');
    }
  }

  Future<void> _addFeaturedStoryDetail(
      String featuredStoryId, List<String> storyIds) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var id in storyIds) {
        final FeaturedStoryDetail featuredStoryDetail = FeaturedStoryDetail(
          featuredStoryId: featuredStoryId,
          storyId: id,
        );
        var documentRef = _featuredStoriesDetailCollection.doc();
        batch.set(documentRef, featuredStoryDetail.asMap());
      }

      await batch.commit();
    } catch (e) {
      // ignore: avoid_print
      print('addFeaturedStoryDetail ERROR ---> $e');
      rethrow;
    }
  }

  Future<List<DocumentSnapshot>> getListStoryByFeaturedStoryId(
      String featuredStoryId) async {
    try {
      final featuredStoryDetail = await _featuredStoriesDetailCollection
          .where(DocumentFieldNames.featuredStoryId, isEqualTo: featuredStoryId)
          .get();
      final List<DocumentSnapshot> stories = [];
      for (var doc in featuredStoryDetail.docs) {
        final docStory = await _storyServices
            .getDocStoryById(doc.data()[DocumentFieldNames.storyId]);
        if (docStory != null) {
          stories.add(docStory);
        }
      }
      return stories;
    } catch (e) {
      // ignore: avoid_print
      print('getListStoryByFeaturedStoryId ERROR ---> $e');
      return [];
    }
  }
}
