import 'package:social_media_app/utils/field_names.dart';

class FeaturedStory {
  final String _uid;
  final String _featuredStoryDescription;
  final String _imageUrl;

  FeaturedStory(
      {required String uid,
      required String featuredStoryDescription,
      required String imageUrl})
      : _uid = uid,
        _featuredStoryDescription = featuredStoryDescription,
        _imageUrl = imageUrl;

  String get uid => _uid;
  String get featuredStoryDescription => _featuredStoryDescription;
  String get imageUrl => _imageUrl;

  factory FeaturedStory.fromMap(Map map) {
    return FeaturedStory(
      uid: map[DocumentFieldNames.uid],
      featuredStoryDescription:
          map[DocumentFieldNames.featuredStoryDescription],
      imageUrl: map[DocumentFieldNames.imageUrl],
    );
  }

  Map<String, dynamic> asMap() => {
        DocumentFieldNames.uid: _uid,
        DocumentFieldNames.featuredStoryDescription: _featuredStoryDescription,
        DocumentFieldNames.imageUrl: _imageUrl,
      };
}
