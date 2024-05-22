import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/utils/field_names.dart';

class Stories {
  final String _uid;
  final String _mediaURL;
  final Timestamp _storyCreatedTime;

  String get uid => _uid;
  String get mediaURL => _mediaURL;
  Timestamp get storyCreatedTime => _storyCreatedTime;

  Stories({
    required String uid,
    required String mediaURL,
    required Timestamp storyCreatedTime,
  })  : _uid = uid,
        _mediaURL = mediaURL,
        _storyCreatedTime = storyCreatedTime;

  factory Stories.fromMap(Map map) {
    return Stories(
      uid: map[DocumentFieldNames.uid],
      mediaURL: map[DocumentFieldNames.mediaURL],
      storyCreatedTime: map[DocumentFieldNames.storyCreatedTime],
    );
  }

  Map<String, dynamic> asMap() => {
        DocumentFieldNames.uid: _uid,
        DocumentFieldNames.mediaURL: _mediaURL,
        DocumentFieldNames.storyCreatedTime: _storyCreatedTime,
      };
}
