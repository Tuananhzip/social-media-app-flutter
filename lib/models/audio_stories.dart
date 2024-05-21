import 'package:social_media_app/utils/field_names.dart';

class AudioStories {
  final String _storyId;
  final String _audioName;
  final String _audioLink;
  final int _position;

  String get storyId => _storyId;
  String get audioName => _audioName;
  String get audioLink => _audioLink;
  int get position => _position;

  AudioStories({
    required String storyId,
    required String audioName,
    required String audioLink,
    required int position,
  })  : _storyId = storyId,
        _audioName = audioName,
        _audioLink = audioLink,
        _position = position;

  factory AudioStories.fromMap(Map map) {
    return AudioStories(
      storyId: map[DocumentFieldNames.senderId],
      audioName: map[DocumentFieldNames.audioName],
      audioLink: map[DocumentFieldNames.audioLink],
      position: map[DocumentFieldNames.position],
    );
  }
  Map<String, dynamic> asMap() => {
        DocumentFieldNames.storyId: _storyId,
        DocumentFieldNames.audioName: _audioName,
        DocumentFieldNames.audioLink: _audioLink,
        DocumentFieldNames.position: _position,
      };
}
