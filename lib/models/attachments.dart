import 'package:social_media_app/utils/field_names.dart';

class Attachments {
  final String _messageId;
  final String _fileName;

  Attachments({required String messageId, required String fileName})
      : _messageId = messageId,
        _fileName = fileName;

  String get messageId => _messageId;
  String get fileName => _fileName;

  factory Attachments.fromMap(Map map) => Attachments(
        messageId: map[DocumentFieldNames.messageId],
        fileName: map[DocumentFieldNames.fileName],
      );

  Map<String, dynamic> asMap() => {
        DocumentFieldNames.messageId: _messageId,
        DocumentFieldNames.fileName: _fileName,
      };
}
