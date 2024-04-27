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

  Posts.formMap(Map map)
      : _uid = map[DocumentFieldNames.uid],
        _postText = map[DocumentFieldNames.postText],
        _postCreatedDate = map[DocumentFieldNames.postCreatedDate],
        _mediaLink = (map[DocumentFieldNames.mediaLink] as List<dynamic>)
            .map((item) => item.toString())
            .toList();

  Map<String, dynamic> asMap() => {
        DocumentFieldNames.uid: _uid,
        DocumentFieldNames.postText: _postText,
        DocumentFieldNames.postCreatedDate: _postCreatedDate,
        DocumentFieldNames.mediaLink: _mediaLink,
      };
}
