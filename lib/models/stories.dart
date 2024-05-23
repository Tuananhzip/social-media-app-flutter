import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/utils/field_names.dart';

class Stories {
  final String _uid;
  final String _mediaURL;
  final String _mediaType;
  final bool? _volume;
  final Timestamp _storyCreatedTime;

  String get uid => _uid;
  String get mediaURL => _mediaURL;
  String get mediaType => _mediaType;
  bool? get volume => _volume;
  Timestamp get storyCreatedTime => _storyCreatedTime;

  Stories({
    required String uid,
    required String mediaURL,
    required String mediaType,
    bool? volume,
    required Timestamp storyCreatedTime,
  })  : _uid = uid,
        _mediaURL = mediaURL,
        _mediaType = mediaType,
        _volume = volume,
        _storyCreatedTime = storyCreatedTime;

  factory Stories.fromMap(Map map) {
    return Stories(
      uid: map[DocumentFieldNames.uid],
      mediaURL: map[DocumentFieldNames.mediaURL],
      mediaType: map[DocumentFieldNames.mediaType],
      volume: map.containsKey(DocumentFieldNames.volume)
          ? map[DocumentFieldNames.volume]
          : null,
      storyCreatedTime: map[DocumentFieldNames.storyCreatedTime],
    );
  }

  Map<String, dynamic> asMap() {
    final map = {
      DocumentFieldNames.uid: _uid,
      DocumentFieldNames.mediaURL: _mediaURL,
      DocumentFieldNames.mediaType: _mediaType,
      DocumentFieldNames.storyCreatedTime: _storyCreatedTime,
    };
    if (_volume != null) {
      map[DocumentFieldNames.volume] = _volume;
    }
    return map;
  }
}
