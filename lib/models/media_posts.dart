import 'package:social_media_app/utils/field_names.dart';

class MediaPosts {
  String? postId;
  String? mediaLink;
  String? mediaType;

  MediaPosts({
    this.postId,
    this.mediaLink,
    this.mediaType,
  });

  MediaPosts.formMap(Map map)
      : this(
          postId: map[DocumentFieldNames.postId],
          mediaLink: map[DocumentFieldNames.mediaLink],
          mediaType: map[DocumentFieldNames.mediaType],
        );

  Map<String, dynamic> asMap() => {
        DocumentFieldNames.postId: postId,
        DocumentFieldNames.mediaLink: mediaLink,
        DocumentFieldNames.mediaType: mediaType,
      };
}
