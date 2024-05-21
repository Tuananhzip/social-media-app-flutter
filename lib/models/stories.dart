import 'package:social_media_app/utils/field_names.dart';

class Stories {
  final String _uid;
  final String _mediaURL;
  final String _storyCreatedTime;

  String get uid => _uid;
  String get mediaURL => _mediaURL;
  String get storyCreatedTime => _storyCreatedTime;

  Stories({
    required String uid,
    required String mediaURL,
    required String storyCreatedTime,
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
