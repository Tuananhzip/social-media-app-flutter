import 'package:social_media_app/utils/field_names.dart';

class FriendRequest {
  final String _senderId;
  final String _receiverId;
  final bool _statusRequest;

  FriendRequest({
    required String senderId,
    required String receiverId,
    required bool statusRequest,
  })  : _senderId = senderId,
        _receiverId = receiverId,
        _statusRequest = statusRequest;

  String get senderId => _senderId;
  String get receiverId => _receiverId;
  bool get statusRequest => _statusRequest;

  FriendRequest.formMap(Map map)
      : this(
          senderId: map[DocumentFieldNames.senderId],
          receiverId: map[DocumentFieldNames.receiverId],
          statusRequest: map[DocumentFieldNames.statusFriendRequest],
        );

  Map<String, dynamic> asMap() => {
        DocumentFieldNames.senderId: _senderId,
        DocumentFieldNames.receiverId: _receiverId,
        DocumentFieldNames.statusFriendRequest: _statusRequest,
      };
}
