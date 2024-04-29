import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/utils/field_names.dart';

class Notifications {
  String? _uid;
  String? _notificationType;
  String? _notificationReferenceId;
  String? _notificationContent;
  Timestamp? _notificationCreatedDate;
  bool? _notificationStatus;

  Notifications({
    String? uid,
    String? notificationType,
    String? notificationReferenceId,
    String? notificationContent,
    Timestamp? notificationCreatedDate,
    bool? notificationStatus,
  })  : _uid = uid,
        _notificationType = notificationType,
        _notificationReferenceId = notificationReferenceId,
        _notificationContent = notificationContent,
        _notificationCreatedDate = notificationCreatedDate,
        _notificationStatus = notificationStatus;

  String? get uid => _uid;
  String? get notificationType => _notificationType;
  String? get notificationReferenceId => _notificationReferenceId;
  String? get notificationContent => _notificationContent;
  Timestamp? get notificationCreatedDate => _notificationCreatedDate;
  bool? get notificationStatus => _notificationStatus;

  factory Notifications.fromMap(Map map) {
    return Notifications(
      uid: map[DocumentFieldNames.uid],
      notificationType: map[DocumentFieldNames.notificationType],
      notificationReferenceId: map[DocumentFieldNames.notificationReferenceId],
      notificationContent: map[DocumentFieldNames.notificationContent],
      notificationCreatedDate: map[DocumentFieldNames.notificationCreatedDate],
      notificationStatus: map[DocumentFieldNames.notificationStatus],
    );
  }

  Map<String, dynamic> asMap() => {
        DocumentFieldNames.uid: _uid,
        DocumentFieldNames.notificationType: _notificationType,
        DocumentFieldNames.notificationReferenceId: _notificationReferenceId,
        DocumentFieldNames.notificationContent: _notificationContent,
        DocumentFieldNames.notificationCreatedDate: _notificationCreatedDate,
        DocumentFieldNames.notificationStatus: _notificationStatus,
      };
}
