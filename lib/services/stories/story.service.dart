import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:social_media_app/utils/field_names.dart';

class StoryServices {
  // final _storyCollection =
  //     FirebaseFirestore.instance.collection(FirestoreCollectionNames.stories);
  final _currentUser = FirebaseAuth.instance.currentUser;

  Future<void> uploadStoryToStorage(Uint8List imageData) async {
    try {
      String fileName = '${DateTime.now().microsecondsSinceEpoch}.jpg';

      Reference ref = FirebaseStorage.instance
          .ref()
          .child(DocumentFieldNames.mediaStoryFile)
          .child(_currentUser!.email!)
          .child(fileName);
      await ref.putData(imageData);
      String downloadURL = await ref.getDownloadURL();

      Logger().d('Uploaded image URL: $downloadURL');
    } catch (error) {
      // ignore: avoid_print
      print("uploadStoryToStorage ERROR ---> $error");
    }
  }
}
