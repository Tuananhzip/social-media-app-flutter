import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/models/post_likes.dart';
import 'package:social_media_app/utils/collection_names.dart';
import 'package:social_media_app/utils/field_names.dart';

class PostLikeServices {
  final currentUser = FirebaseAuth.instance.currentUser;
  final CollectionReference _postLikesCollection =
      FirebaseFirestore.instance.collection(FirestoreCollectionNames.postLikes);

  Future<void> likePost(String postId) async {
    try {
      PostLikes newLike = PostLikes(
        postId: postId,
        userId: currentUser!.uid,
      );
      await _postLikesCollection.add(newLike.asMap());
    } catch (e) {
      // ignore: avoid_print
      print('likePost ERROR ---> $e');
    }
  }

  Future<void> unlikePost(String postId) async {
    try {
      await _postLikesCollection
          .where(DocumentFieldNames.postId, isEqualTo: postId)
          .where(DocumentFieldNames.uid, isEqualTo: currentUser!.uid)
          .get()
          .then((value) {
        for (var element in value.docs) {
          element.reference.delete();
        }
      });
    } catch (e) {
      // ignore: avoid_print
      print('unlikePost ERROR ---> $e');
    }
  }

  Future<int> getQuantityPostLikes(String postId) async {
    try {
      QuerySnapshot querySnapshot = await _postLikesCollection
          .where(DocumentFieldNames.postId, isEqualTo: postId)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      // ignore: avoid_print
      print('getQuantityPostLikes ERROR ---> $e');
      return 0;
    }
  }

  Future<bool> isUserLikedPost(String postId) async {
    QuerySnapshot querySnapshot = await _postLikesCollection
        .where(DocumentFieldNames.postId, isEqualTo: postId)
        .where(DocumentFieldNames.uid, isEqualTo: currentUser!.uid)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<List<String>> getUsersLikedPost(String postId) async {
    try {
      QuerySnapshot querySnapshot = await _postLikesCollection
          .where(DocumentFieldNames.postId, isEqualTo: postId)
          .get();
      if (querySnapshot.docs.isEmpty) return [];
      List<String> uids = [];
      for (var doc in querySnapshot.docs) {
        uids.add(doc[DocumentFieldNames.uid]);
      }
      return uids;
    } catch (e) {
      // ignore: avoid_print
      print('getPostLikes ERROR ---> $e');
      return [];
    }
  }
}
