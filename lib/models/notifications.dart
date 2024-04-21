import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/utils/field_names.dart';

class Notifications {
  String? uid;
  String? notificationType;
  String? notificationReferenceId;
  String? notificationContent;
  Timestamp? notificationCreatedDate;
  bool? notificationStatus;

  Notifications({
    this.uid,
    this.notificationType,
    this.notificationReferenceId,
    this.notificationContent,
    this.notificationCreatedDate,
    this.notificationStatus,
  });

  Notifications.formMap(Map map)
      : this(
          uid: map[DocumentFieldNames.uid],
          notificationType: map[DocumentFieldNames.notificationType],
          notificationReferenceId:
              map[DocumentFieldNames.notificationReferenceId],
          notificationContent: map[DocumentFieldNames.notificationContent],
          notificationCreatedDate:
              map[DocumentFieldNames.notificationCreatedDate],
          notificationStatus: map[DocumentFieldNames.notificationStatus],
        );

  Map<String, dynamic> asMap() => {
        DocumentFieldNames.uid: uid,
        DocumentFieldNames.notificationType: notificationType,
        DocumentFieldNames.notificationReferenceId: notificationReferenceId,
        DocumentFieldNames.notificationContent: notificationContent,
        DocumentFieldNames.notificationCreatedDate: notificationCreatedDate,
        DocumentFieldNames.notificationStatus: notificationStatus,
      };
}
