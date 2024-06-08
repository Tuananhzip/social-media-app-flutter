import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/utils/field_names.dart';

class Messages {
  final String _senderId;
  final String _recipientId;
  final String _messageContent;
  final Timestamp _messageCreatedTime;

  Messages(
      {required String senderId,
      required String recipientId,
      required String messageContent,
      required Timestamp messageCreatedTime})
      : _senderId = senderId,
        _recipientId = recipientId,
        _messageContent = messageContent,
        _messageCreatedTime = messageCreatedTime;

  String get senderId => _senderId;
  String get recipientId => _recipientId;
  String get messageContent => _messageContent;
  Timestamp get messageCreatedTime => _messageCreatedTime;

  factory Messages.fromMap(Map map) => Messages(
        senderId: map[DocumentFieldNames.senderId],
        recipientId: map[DocumentFieldNames.recipientId],
        messageContent: map[DocumentFieldNames.messageContent],
        messageCreatedTime: map[DocumentFieldNames.messageCreatedTime],
      );

  Map<String, dynamic> asMap() => {
        DocumentFieldNames.senderId: _senderId,
        DocumentFieldNames.recipientId: _recipientId,
        DocumentFieldNames.messageContent: _messageContent,
        DocumentFieldNames.messageCreatedTime: _messageCreatedTime,
      };
}
