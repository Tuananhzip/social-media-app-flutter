import 'package:social_media_app/utils/field_names.dart';

class FriendRequest {
  final String senderId;
  final String receiverId;
  final bool statusRequest;

  FriendRequest({
    required this.senderId,
    required this.receiverId,
    required this.statusRequest,
  });

  FriendRequest.formMap(Map map)
      : senderId = map[DocumentFieldNames.senderId],
        receiverId = map[DocumentFieldNames.receiverId],
        statusRequest = map[DocumentFieldNames.statusFriendRequest];

  Map<String, dynamic> asMap() => {
        DocumentFieldNames.senderId: senderId,
        DocumentFieldNames.receiverId: receiverId,
        DocumentFieldNames.statusFriendRequest: statusRequest,
      };
}
