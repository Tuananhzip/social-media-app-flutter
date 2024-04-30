import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/utils/field_names.dart';

class PostComments {
  final String _postId;
  final String _uid;
  final String _commentText;
  final Timestamp _commentCreatedTime;

  String get postId => _postId;
  String get uid => _uid;
  String get commentText => _commentText;
  Timestamp get commentCreatedTime => _commentCreatedTime;

  PostComments({
    required String postId,
    required String uid,
    required String commentText,
    required Timestamp commentCreatedTime,
  })  : _postId = postId,
        _uid = uid,
        _commentText = commentText,
        _commentCreatedTime = commentCreatedTime;

  factory PostComments.fromMap(Map map) {
    return PostComments(
      postId: map[DocumentFieldNames.postId],
      uid: map[DocumentFieldNames.uid],
      commentText: map[DocumentFieldNames.commentText],
      commentCreatedTime: map[DocumentFieldNames.commentCreatedTime],
    );
  }

  Map<String, dynamic> asMap() => {
        DocumentFieldNames.postId: _postId,
        DocumentFieldNames.uid: _uid,
        DocumentFieldNames.commentText: _commentText,
        DocumentFieldNames.commentCreatedTime: _commentCreatedTime,
      };
}
