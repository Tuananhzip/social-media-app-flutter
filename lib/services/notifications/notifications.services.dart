import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/models/notifications.dart';
import 'package:social_media_app/utils/collection_names.dart';
import 'package:social_media_app/utils/field_names.dart';
import 'package:social_media_app/utils/my_enum.dart';

class NotificationServices {
  final notificationsCollection = FirebaseFirestore.instance
      .collection(FirestoreCollectionNames.notifications);
  final currentUser = FirebaseAuth.instance.currentUser;
  Future<void> sendNotificationFriendRequest(String receiverId) async {
    Notifications notification = Notifications(
      uid: receiverId,
      notificationType: NotificationTypeEnum.friendRequest.getString,
      notificationReferenceId: currentUser!.uid,
      notificationContent: 'You have received a friend request.',
      notificationCreatedDate: Timestamp.now(),
      notificationStatus: false,
    );
    await notificationsCollection.add(notification.asMap());
  }

  Future<void> cancelNotificationFriendRequest(String receiverId) async {
    try {
      QuerySnapshot querySnapshot = await notificationsCollection
          .where(DocumentFieldNames.uid, isEqualTo: receiverId)
          .where(DocumentFieldNames.notificationReferenceId,
              isEqualTo: currentUser!.uid)
          .where(DocumentFieldNames.notificationType,
              isEqualTo: NotificationTypeEnum.friendRequest.getString)
          .get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (error) {
      //ignore:avoid_print
      print("cancelNotificationFriendRequest ERROR ---> $error");
    }
  }

  Future<void> deleteNotificationFriendRequest(String senderId) async {
    try {
      QuerySnapshot querySnapshot = await notificationsCollection
          .where(DocumentFieldNames.uid, isEqualTo: currentUser!.uid)
          .where(DocumentFieldNames.notificationReferenceId,
              isEqualTo: senderId)
          .where(DocumentFieldNames.notificationType,
              isEqualTo: NotificationTypeEnum.friendRequest.getString)
          .get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (error) {
      //ignore:avoid_print
      print("deleteNotificationFriendRequest ERROR ---> $error");
    }
  }

  Future<void> acceptNotificationFriendRequest(String senderId) async {
    try {
      QuerySnapshot querySnapshot = await notificationsCollection
          .where(DocumentFieldNames.uid, isEqualTo: currentUser!.uid)
          .where(DocumentFieldNames.notificationReferenceId,
              isEqualTo: senderId)
          .where(DocumentFieldNames.notificationType,
              isEqualTo: NotificationTypeEnum.friendRequest.getString)
          .get();
      for (var doc in querySnapshot.docs) {
        String docId = doc.id;
        await notificationsCollection.doc(docId).update({
          DocumentFieldNames.notificationContent:
              'Your friend request has been accepted',
          DocumentFieldNames.notificationCreatedDate: Timestamp.now(),
          DocumentFieldNames.notificationType:
              NotificationTypeEnum.acceptFriend.getString,
          DocumentFieldNames.notificationStatus: false,
        });
      }
    } catch (error) {
      //ignore:avoid_print
      print("acceptNotificationFriendRequest ERROR ---> $error");
    }
  }

  Stream<List<Notifications>> getNotificationsForFriendRequest() {
    return notificationsCollection
        .where(DocumentFieldNames.uid, isEqualTo: currentUser!.uid)
        .where(DocumentFieldNames.notificationType,
            isEqualTo: NotificationTypeEnum.friendRequest.getString)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Notifications.formMap(doc.data()))
            .toList());
  }

  Stream<List<Notifications>> getNotificationsForAcceptedFriendRequest() {
    return notificationsCollection
        .where(DocumentFieldNames.notificationReferenceId,
            isEqualTo: currentUser!.uid)
        .where(DocumentFieldNames.notificationType,
            isEqualTo: NotificationTypeEnum.acceptFriend.getString)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Notifications.formMap(doc.data()))
            .toList());
  }
}
