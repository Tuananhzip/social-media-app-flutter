import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/models/notifications.dart';
import 'package:social_media_app/utils/collection_names.dart';
import 'package:social_media_app/utils/field_names.dart';
import 'package:social_media_app/utils/my_enum.dart';

class NotificationServices {
  final _notificationsCollection = FirebaseFirestore.instance
      .collection(FirestoreCollectionNames.notifications);
  final _currentUser = FirebaseAuth.instance.currentUser;
  Future<void> sendNotificationFriendRequest(String receiverId) async {
    Notifications notification = Notifications(
      uid: receiverId,
      notificationType: NotificationTypeEnum.friendRequest.getString,
      notificationReferenceId: _currentUser!.uid,
      notificationContent: 'You have received a friend request.',
      notificationCreatedDate: Timestamp.now(),
      notificationStatus: false,
    );
    await _notificationsCollection.add(notification.asMap());
  }

  Query _getNotificationQuery({
    required String uid,
    required String referenceId,
    required String type,
  }) {
    return _notificationsCollection
        .where(DocumentFieldNames.uid, isEqualTo: uid)
        .where(DocumentFieldNames.notificationReferenceId,
            isEqualTo: referenceId)
        .where(DocumentFieldNames.notificationType, isEqualTo: type);
  }

  Future<void> cancelNotificationFriendRequest(String receiverId) async {
    try {
      QuerySnapshot querySnapshot = await _getNotificationQuery(
        uid: receiverId,
        referenceId: _currentUser!.uid,
        type: NotificationTypeEnum.friendRequest.getString,
      ).get();
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
      QuerySnapshot querySnapshot = await _getNotificationQuery(
        uid: _currentUser!.uid,
        referenceId: senderId,
        type: NotificationTypeEnum.friendRequest.getString,
      ).get();
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
      QuerySnapshot querySnapshot = await _getNotificationQuery(
        uid: _currentUser!.uid,
        referenceId: senderId,
        type: NotificationTypeEnum.friendRequest.getString,
      ).get();
      for (var doc in querySnapshot.docs) {
        String docId = doc.id;
        await _notificationsCollection.doc(docId).update({
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
    return _notificationsCollection
        .where(DocumentFieldNames.uid, isEqualTo: _currentUser!.uid)
        .where(DocumentFieldNames.notificationType,
            isEqualTo: NotificationTypeEnum.friendRequest.getString)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Notifications.fromMap(doc.data()))
            .toList());
  }

  Stream<List<Notifications>> getNotificationsForAcceptedFriendRequest() {
    return _notificationsCollection
        .where(DocumentFieldNames.notificationReferenceId,
            isEqualTo: _currentUser!.uid)
        .where(DocumentFieldNames.notificationType,
            isEqualTo: NotificationTypeEnum.acceptFriend.getString)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Notifications.fromMap(doc.data()))
            .toList());
  }
}
