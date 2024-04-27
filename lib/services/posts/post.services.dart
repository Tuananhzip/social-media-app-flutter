import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_media_app/models/posts.dart';
import 'package:social_media_app/utils/collection_names.dart';
import 'package:social_media_app/utils/field_names.dart';

class PostService {
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

  Future<List<DocumentSnapshot>> loadPostsLazy(
      {limit = 10, DocumentSnapshot? lastVisible}) async {
    Query query = _postCollection
        .orderBy(DocumentFieldNames.postCreatedDate, descending: true)
        .limit(limit);

    if (lastVisible != null) {
      query = query.startAfterDocument(lastVisible);
    }

    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs;
  }

  Stream<List<Posts>> getPostsStream() {
    return _postCollection
        .orderBy(DocumentFieldNames.postCreatedDate, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Posts.formMap(doc.data() as Map<String, dynamic>))
            .toList());
  }
}
