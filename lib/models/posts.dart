import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/utils/field_names.dart';

class Posts {
  final String? _uid;
  final String? _postText;
  final Timestamp? _postCreatedDate;
  final List<String>? _mediaLink;

  String? get uid => _uid;
  String? get postText => _postText;
  Timestamp? get postCreatedDate => _postCreatedDate;
  List<String>? get mediaLink => _mediaLink;

  Posts({
    String? uid,
    String? postText,
    Timestamp? postCreatedDate,
    List<String>? mediaLink,
  })  : _uid = uid,
        _postText = postText,
        _postCreatedDate = postCreatedDate,
        _mediaLink = mediaLink;

  factory Posts.fromMap(Map<String, dynamic> map) {
    return Posts(
      uid: map[DocumentFieldNames.uid],
      postText: map[DocumentFieldNames.postText],
      postCreatedDate: map[DocumentFieldNames.postCreatedDate],
      mediaLink: (map[DocumentFieldNames.mediaLink] as List<dynamic>)
          .map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> asMap() => {
        DocumentFieldNames.uid: _uid,
        DocumentFieldNames.postText: _postText,
        DocumentFieldNames.postCreatedDate: _postCreatedDate,
        DocumentFieldNames.mediaLink: _mediaLink,
      };
}
