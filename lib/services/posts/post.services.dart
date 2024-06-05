import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_media_app/models/posts.dart';
import 'package:social_media_app/services/postComments/post_comment.services.dart';
import 'package:social_media_app/services/postLikes/post_like.service.dart';
import 'package:social_media_app/utils/collection_names.dart';
import 'package:social_media_app/utils/field_names.dart';

class PostService {
  final PostCommentServices _postCommentServices = PostCommentServices();
  final PostLikeServices _postLikeServices = PostLikeServices();
  final _currentUser = FirebaseAuth.instance.currentUser;
  final CollectionReference _postCollection =
      FirebaseFirestore.instance.collection(FirestoreCollectionNames.posts);

  Future<List<String>> uploadMediaToStorage(List<File> files) async {
    try {
      List<String> listUrl = [];
      await Future.wait(files.map((file) async {
        String fileType = file.path.split('.').last; // get mp4 or jpg ...
        String fileName = '${DateTime.now().microsecondsSinceEpoch}.$fileType';
        Reference ref = FirebaseStorage.instance
            .ref()
            .child(DocumentFieldNames.mediaPostFile)
            .child(_currentUser!.email!)
            .child(fileName);
        UploadTask uploadTask = ref.putFile(file);
        TaskSnapshot downloadUrl = await uploadTask;
        String url = await downloadUrl.ref.getDownloadURL();
        listUrl.add(url);
      }));
      return listUrl;
    } catch (error) {
      //ignore:avoid_print
      print('uploadImageToStorage ERROR ---> $error');
    }
    return [];
  }

  Future<void> addPostToFirestore(String postText, List<File> files) async {
    try {
      List<String> fileUrls = await uploadMediaToStorage(files);
      final postData = Posts(
        uid: _currentUser!.uid,
        postText: postText,
        postCreatedDate: Timestamp.now(),
        mediaLink: fileUrls,
      ).asMap();
      await _postCollection.add(postData);
    } catch (error) {
      //ignore:avoid_print
      print('addPostToFirestore ERROR ---> $error');
    }
  }

  Stream<List<Posts>> getPostsStream() {
    return _postCollection
        .orderBy(DocumentFieldNames.postCreatedDate, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Posts.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> deletePost(String postId) async {
    try {
      DocumentSnapshot postSnapshot = await _postCollection.doc(postId).get();

      List<String> mediaLinks =
          List<String>.from(postSnapshot.get(DocumentFieldNames.mediaLink));
      FirebaseStorage storage = FirebaseStorage.instance;
      for (String mediaLink in mediaLinks) {
        Reference ref = storage.refFromURL(mediaLink);
        await ref.delete();
      }
      await _postLikeServices.deletePostLikes(postId);
      await _postCommentServices.deletePostComment(postId);
      await _postCollection.doc(postId).delete();
    } catch (error) {
      //ignore:avoid_print
      print('deletePost ERROR ---> $error');
    }
  }

  Future<List<DocumentSnapshot>> getListPostByUserId(String uid) async {
    try {
      QuerySnapshot querySnapshot = await _postCollection
          .where(DocumentFieldNames.uid, isEqualTo: uid)
          .orderBy(DocumentFieldNames.postCreatedDate, descending: true)
          .get();
      return querySnapshot.docs;
    } catch (error) {
      //ignore:avoid_print
      print('getListPostsForCurrentUser ERROR ---> $error');
    }
    return [];
  }

  Future<int> getCountListPostByUserId(String uid) async {
    try {
      QuerySnapshot querySnapshot = await _postCollection
          .where(DocumentFieldNames.uid, isEqualTo: uid)
          .get();
      return querySnapshot.docs.length;
    } catch (error) {
      //ignore:avoid_print
      print('getCountListPostForCurrentUser ERROR ---> $error');
    }
    return 0;
  }

  Future<List<DocumentSnapshot>> loadPostsLazy(
      {DocumentSnapshot? lastVisible}) async {
    Query query = _postCollection
        .orderBy(DocumentFieldNames.postCreatedDate, descending: true)
        .limit(10);

    if (lastVisible != null) {
      query = query.startAfterDocument(lastVisible);
    }

    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs;
  }

  Future<List<DocumentSnapshot>> getListPostByListId(
      List<String> listId) async {
    List<DocumentSnapshot> listPosts = [];
    try {
      for (String id in listId) {
        final docSnapshot = await _postCollection.doc(id).get();
        if (docSnapshot.exists) {
          listPosts.add(docSnapshot);
        }
      }
      return listPosts;
    } catch (e) {
      //ignore:avoid_print
      print(e);
      return [];
    }
  }

  Future<QuerySnapshot> searchPosts(String query) async {
    return await _postCollection
        .where(DocumentFieldNames.postText, isGreaterThanOrEqualTo: query)
        .where(DocumentFieldNames.postText, isLessThanOrEqualTo: '$query\uf8ff')
        .get();
  }
}
