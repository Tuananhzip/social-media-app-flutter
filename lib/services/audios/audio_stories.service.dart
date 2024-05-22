import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/models/audio_stories.dart';
import 'package:social_media_app/utils/collection_names.dart';
import 'package:social_media_app/utils/field_names.dart';

class AudioStoriesServices {
  final _audioCollection = FirebaseFirestore.instance
      .collection(FirestoreCollectionNames.audioStories);

  Future<void> addAudioStory(
      String storyId, String audioName, String audioLink, int position) async {
    try {
      final audioStory = AudioStories(
        storyId: storyId,
        audioName: audioName,
        audioLink: audioLink,
        position: position,
      );
      await _audioCollection.add(audioStory.asMap());
    } catch (e) {
      // ignore: avoid_print
      print('addAudioStory ERROR ---> $e');
    }
  }

  Future<AudioStories?> getAudioByStoryId(String storyId) async {
    try {
      final audioStory = await _audioCollection
          .where(DocumentFieldNames.storyId, isEqualTo: storyId)
          .get();
      if (audioStory.docs.isNotEmpty) {
        return AudioStories.fromMap(audioStory.docs.first.data());
      }
    } catch (e) {
      // ignore: avoid_print
      print('getAudioByStoryId ERROR ---> $e');
    }
    return null;
  }
}
