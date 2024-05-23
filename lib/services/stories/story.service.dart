import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_media_app/models/stories.dart';
import 'package:social_media_app/utils/collection_names.dart';
import 'package:social_media_app/utils/field_names.dart';
import 'package:social_media_app/utils/my_enum.dart';

class StoryServices {
  final _storyCollection =
      FirebaseFirestore.instance.collection(FirestoreCollectionNames.stories);
  final _currentUser = FirebaseAuth.instance.currentUser;

  Future<String> uploadStoryToStorage(Uint8List imageData) async {
    try {
      String fileName = '${DateTime.now().microsecondsSinceEpoch}.jpg';

      Reference ref = FirebaseStorage.instance
          .ref()
          .child(DocumentFieldNames.mediaStoryFile)
          .child(_currentUser!.email!)
          .child(fileName);
      await ref.putData(imageData);
      String downloadURL = await ref.getDownloadURL();
      return downloadURL;
    } catch (error) {
      // ignore: avoid_print
      print("uploadStoryToStorage ERROR ---> $error");
      return '';
    }
  }

  Future<String?> addStory(Uint8List imageData) async {
    try {
      final mediaURL = await uploadStoryToStorage(imageData);
      final Stories story = Stories(
        uid: _currentUser!.uid,
        mediaURL: mediaURL,
        mediaType: MediaTypeEnum.image.name,
        storyCreatedTime: Timestamp.now(),
      );
      final DocumentReference docRef =
          await _storyCollection.add(story.asMap());
      return docRef.id;
    } catch (e) {
      // ignore: avoid_print
      print('addStory ERROR ---> $e');
      return null;
    }
  }

  Future<List<DocumentSnapshot>> getAllStory() async {
    try {
      final QuerySnapshot querySnapshot = await _storyCollection.get();
      return querySnapshot.docs;
    } catch (e) {
      // ignore: avoid_print
      print('getAllStory ERROR ---> $e');
      return [];
    }
  }

  Future<Stories?> getStoryById(String docId) async {
    try {
      final DocumentSnapshot docSnapshot =
          await _storyCollection.doc(docId).get();
      return Stories.fromMap(docSnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      // ignore: avoid_print
      print('getStoryById ERROR ---> $e');
      return null;
    }
  }
}
