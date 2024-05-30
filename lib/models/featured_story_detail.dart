import 'package:social_media_app/utils/field_names.dart';

class FeaturedStoryDetail {
  final String _featuredStoryId;
  final String _storyId;

  FeaturedStoryDetail(
      {required String featuredStoryId, required String storyId})
      : _featuredStoryId = featuredStoryId,
        _storyId = storyId;

  String get featuredStoryId => _featuredStoryId;
  String get storyId => _storyId;

  factory FeaturedStoryDetail.fromMap(Map map) {
    return FeaturedStoryDetail(
      featuredStoryId: map[DocumentFieldNames.featuredStoryId],
      storyId: map[DocumentFieldNames.storyId],
    );
  }

  Map<String, dynamic> asMap() => {
        DocumentFieldNames.featuredStoryId: _featuredStoryId,
        DocumentFieldNames.storyId: _storyId,
      };
}
