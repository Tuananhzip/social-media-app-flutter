import 'package:social_media_app/utils/field_names.dart';

class PostLikes {
  final String _postId;
  final String _userId;

  String get postId => _postId;
  String get userId => _userId;

  PostLikes({
    required String postId,
    required String userId,
  })  : _postId = postId,
        _userId = userId;

  factory PostLikes.fromMap(Map map) {
    return PostLikes(
      postId: map[DocumentFieldNames.postId],
      userId: map[DocumentFieldNames.uid],
    );
  }

  Map<String, dynamic> asMap() => {
        DocumentFieldNames.postId: _postId,
        DocumentFieldNames.uid: _userId,
      };
}
