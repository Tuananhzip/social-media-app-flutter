import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/models/notifications.dart';
import 'package:social_media_app/services/users/user.services.dart';
import 'package:social_media_app/utils/collection_names.dart';
import 'package:social_media_app/utils/field_names.dart';
import 'package:social_media_app/utils/my_enum.dart';

class NotificationServices {
  final UserServices _userServices = UserServices();
  final _notificationsCollection = FirebaseFirestore.instance
      .collection(FirestoreCollectionNames.notifications);
  final _currentUser = FirebaseAuth.instance.currentUser;
  Future<void> sendNotificationFriendRequest(String receiverId) async {
    Notifications notification = Notifications(
      uid: receiverId,
      notificationType: NotificationTypeEnum.friendRequest.name,
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
        type: NotificationTypeEnum.friendRequest.name,
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
        type: NotificationTypeEnum.friendRequest.name,
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
        type: NotificationTypeEnum.friendRequest.name,
      ).get();
      for (var doc in querySnapshot.docs) {
        String docId = doc.id;
        final user = await _userServices.getUserDetailsByID(_currentUser.uid);
        await updateNotification(docId, user!.username!, senderId);
      }
    } catch (error) {
      //ignore:avoid_print
      print("acceptNotificationFriendRequest ERROR ---> $error");
    }
  }

  Future<void> updateNotification(
      String docId, String username, String receiverId) async {
    final Notifications notification = Notifications(
      uid: receiverId,
      notificationReferenceId: _currentUser!.uid,
      notificationContent: '$username has accepted your friend request',
      notificationCreatedDate: Timestamp.now(),
      notificationType: NotificationTypeEnum.acceptFriend.name,
      notificationStatus: false,
    );
    await _notificationsCollection.doc(docId).update(notification.asMap());
  }

  Stream<List<Notifications>> getNotificationsForFriendRequest() {
    return _notificationsCollection
        .where(DocumentFieldNames.uid, isEqualTo: _currentUser!.uid)
        .where(DocumentFieldNames.notificationType,
            isEqualTo: NotificationTypeEnum.friendRequest.name)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Notifications.fromMap(doc.data()))
            .toList());
  }

  Stream<List<QueryDocumentSnapshot>> getNotifications() {
    return _notificationsCollection
        .where(DocumentFieldNames.uid, isEqualTo: _currentUser!.uid)
        .where(DocumentFieldNames.notificationType,
            isNotEqualTo: NotificationTypeEnum.friendRequest.name)
        .orderBy(DocumentFieldNames.notificationCreatedDate, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.where((doc) {
              final notificationType = doc[DocumentFieldNames.notificationType];
              return notificationType != NotificationTypeEnum.message.name;
            }).toList());
  }

  Stream<bool> checkNotifications() {
    return _notificationsCollection
        .where(DocumentFieldNames.uid, isEqualTo: _currentUser!.uid)
        .where(DocumentFieldNames.notificationStatus, isEqualTo: false)
        .where(DocumentFieldNames.notificationType,
            isNotEqualTo: NotificationTypeEnum.message.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  Future<void> updateStatusNotificationTypeFriendRequests() async {
    try {
      QuerySnapshot querySnapshot = await _notificationsCollection
          .where(DocumentFieldNames.uid, isEqualTo: _currentUser!.uid)
          .where(DocumentFieldNames.notificationStatus, isEqualTo: false)
          .get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.update({
          DocumentFieldNames.notificationStatus: true,
        });
      }
    } catch (error) {
      //ignore:avoid_print
      print("updateStatusNotification ERROR ---> $error");
    }
  }

  Future<void> sendNotificationTypeComment(
      String username, String uidOfPost) async {
    final Notifications notification = Notifications(
      uid: uidOfPost,
      notificationType: NotificationTypeEnum.comment.name,
      notificationReferenceId: _currentUser!.uid,
      notificationContent: '$username commented on your post.',
      notificationCreatedDate: Timestamp.now(),
      notificationStatus: false,
    );
    await _notificationsCollection.add(notification.asMap());
  }

  Future<void> markAsSeenNotifications(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({
      DocumentFieldNames.notificationStatus: true,
    });
  }

  Future<void> sendNotificationTypeMessage(
      String senderId, String usernameSender, String reciepientId) async {
    final Notifications notification = Notifications(
      uid: reciepientId,
      notificationType: NotificationTypeEnum.message.name,
      notificationReferenceId: senderId,
      notificationContent: '$usernameSender sent you a message.',
      notificationCreatedDate: Timestamp.now(),
      notificationStatus: false,
    );
    QuerySnapshot query = await _notificationsCollection
        .where(DocumentFieldNames.uid, isEqualTo: reciepientId)
        .where(DocumentFieldNames.notificationReferenceId, isEqualTo: senderId)
        .where(DocumentFieldNames.notificationType,
            isEqualTo: NotificationTypeEnum.message.name)
        .get();
    if (query.docs.isEmpty) {
      await _notificationsCollection.add(notification.asMap());
    } else {
      query.docs.first.reference.update(
        {
          DocumentFieldNames.notificationStatus: false,
          DocumentFieldNames.messageCreatedTime: Timestamp.now(),
        },
      );
    }
  }

  Stream<int> checkNotificationMessage() {
    try {
      return _notificationsCollection
          .where(DocumentFieldNames.uid, isEqualTo: _currentUser!.uid)
          .where(DocumentFieldNames.notificationType,
              isEqualTo: NotificationTypeEnum.message.name)
          .where(DocumentFieldNames.notificationStatus, isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (e) {
      // ignore: avoid_print
      print("checkNotificationMessage ERROR ----> $e");
    }
    return Stream.value(0);
  }

  Stream<bool> checkNotificationMessageForUser(String userId) {
    try {
      return _notificationsCollection
          .where(DocumentFieldNames.uid, isEqualTo: _currentUser!.uid)
          .where(DocumentFieldNames.notificationReferenceId, isEqualTo: userId)
          .where(DocumentFieldNames.notificationType,
              isEqualTo: NotificationTypeEnum.message.name)
          .where(DocumentFieldNames.notificationStatus, isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.isNotEmpty);
    } catch (e) {
      // ignore: avoid_print
      print("checkNotificationMessageForUser ERROR ----> $e");
    }
    return Stream.value(false);
  }

  Future<void> markAsSeenNotificationMessage(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _notificationsCollection
          .where(DocumentFieldNames.uid, isEqualTo: _currentUser!.uid)
          .where(DocumentFieldNames.notificationReferenceId, isEqualTo: userId)
          .where(DocumentFieldNames.notificationType,
              isEqualTo: NotificationTypeEnum.message.name)
          .where(DocumentFieldNames.notificationStatus, isEqualTo: false)
          .get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.update({
          DocumentFieldNames.notificationStatus: true,
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("markAsSeenNotificationMessage ERROR ----> $e");
    }
  }
}
