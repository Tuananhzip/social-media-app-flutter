import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/utils/field_names.dart';

class Posts {
  String? uid;
  String? postText;
  Timestamp? postCreatedDate;

  Posts({
    this.uid,
    this.postText,
    this.postCreatedDate,
  });

  Posts.formMap(Map map)
      : this(
          uid: map[DocumentFieldNames.uid],
          postText: map[DocumentFieldNames.postText],
          postCreatedDate: map[DocumentFieldNames.postCreatedDate],
        );

  Map<String, dynamic> asMap() => {
        DocumentFieldNames.uid: uid,
        DocumentFieldNames.postText: postText,
        DocumentFieldNames.postCreatedDate: postCreatedDate,
      };
}
