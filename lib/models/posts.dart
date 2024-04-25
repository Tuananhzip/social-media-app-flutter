import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/utils/field_names.dart';

class Posts {
  String? uid;
  String? postText;
  Timestamp? postCreatedDate;
  List<String>? mediaLink;

  Posts({
    this.uid,
    this.postText,
    this.postCreatedDate,
    this.mediaLink,
  });

  Posts.formMap(Map map)
      : this(
          uid: map[DocumentFieldNames.uid],
          postText: map[DocumentFieldNames.postText],
          postCreatedDate: map[DocumentFieldNames.postCreatedDate],
          mediaLink: (map[DocumentFieldNames.mediaLink] as List<dynamic>)
              .map((item) => item.toString())
              .toList(),
        );

  Map<String, dynamic> asMap() => {
        DocumentFieldNames.uid: uid,
        DocumentFieldNames.postText: postText,
        DocumentFieldNames.postCreatedDate: postCreatedDate,
        DocumentFieldNames.mediaLink: mediaLink,
      };
}
