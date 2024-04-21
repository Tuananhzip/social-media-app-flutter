import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:social_media_app/models/friend_requests.dart';
import 'package:social_media_app/services/notifications/notifications.services.dart';
import 'package:social_media_app/utils/field_names.dart';
import 'package:social_media_app/utils/collection_names.dart';

class FriendRequestsServices {
  final currentUser = FirebaseAuth.instance.currentUser;
  final friendRequestsCollections = FirebaseFirestore.instance
      .collection(FirestoreCollectionNames.friendRequests);
  final NotificationServices notificationServices = NotificationServices();
  Future<void> sentRequestAddFriend(String receiverId) async {
    try {
      await friendRequestsCollections.add({
        DocumentFieldNames.senderId: currentUser!.uid,
        DocumentFieldNames.receiverId: receiverId,
        DocumentFieldNames.statusFriendRequest: false,
      });
      await notificationServices.sendNotificationFriendRequest(receiverId);
      //ignore: avoid_print
      print('sentRequestAddFriend ---> Successfully');
    } catch (error) {
      //ignore: avoid_print
      print('ERROR sentRequestAddFriend ---> $error');
    }
  }

  Future<void> cancelRequestAddFriend(String receiverId) async {
    try {
      await friendRequestsCollections
          .where(DocumentFieldNames.senderId, isEqualTo: currentUser!.uid)
          .where(DocumentFieldNames.receiverId, isEqualTo: receiverId)
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      await notificationServices.cancelNotificationFriendRequest(receiverId);
      // ignore: avoid_print
      print('cancelRequestAddFriend ---> Successfully');
    } catch (error) {
      //ignore: avoid_print
      print('ERROR cancelRequestAddFriend ---> $error');
    }
  }

  Future<void> deleteRequestAddFriend(String senderId) async {
    try {
      await friendRequestsCollections
          .where(DocumentFieldNames.senderId, isEqualTo: senderId)
          .where(DocumentFieldNames.receiverId, isEqualTo: currentUser!.uid)
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      await notificationServices.deleteNotificationFriendRequest(senderId);
      //ignore:avoid_print
      print('deleteRequestAddFriend ---> Successfully');
    } catch (error) {
      //ignore:avoid_print
      print('deleteRequestAddFriend ERROR ---> $error');
    }
  }

  Future<void> acceptRequestAddFriend(String senderId) async {
    try {
      QuerySnapshot querySnapshot = await friendRequestsCollections
          .where(DocumentFieldNames.senderId, isEqualTo: senderId)
          .where(DocumentFieldNames.receiverId, isEqualTo: currentUser!.uid)
          .where(DocumentFieldNames.statusFriendRequest, isEqualTo: false)
          .get();
      for (var doc in querySnapshot.docs) {
        String docId = doc.id;
        if (docId.isNotEmpty) {
          await friendRequestsCollections
              .doc(docId)
              .update({DocumentFieldNames.statusFriendRequest: true});
        }
      }
      await notificationServices.acceptNotificationFriendRequest(senderId);
    } catch (error) {
      //ignore:avoid_print
      print("acceptRequestAddFriend ERROR ---> $error");
    }
  }

  // Tạm thời sử dụng hàm này
  Stream<bool?> checkFriendRequests(String senderIdOrReceiverId) {
    BehaviorSubject<bool?> senderSubject = BehaviorSubject<bool?>();
    BehaviorSubject<bool?> receiverSubject = BehaviorSubject<bool?>();

    friendRequestsCollections
        .where(DocumentFieldNames.senderId, isEqualTo: currentUser!.uid)
        .where(DocumentFieldNames.receiverId, isEqualTo: senderIdOrReceiverId)
        .snapshots()
        .map(
      (snapshot) {
        final isPendingFriendRequest = snapshot.docs
            .any((doc) => doc[DocumentFieldNames.statusFriendRequest] == false);

        final isSuccessFriendRequest = snapshot.docs
            .any((doc) => doc[DocumentFieldNames.statusFriendRequest] == true);

        if (isPendingFriendRequest) {
          return false;
        } else if (isSuccessFriendRequest) {
          return true;
        } else {
          return null;
        }
      },
    ).listen((event) {
      senderSubject.add(event);
    });
    friendRequestsCollections
        .where(DocumentFieldNames.senderId, isEqualTo: senderIdOrReceiverId)
        .where(DocumentFieldNames.receiverId, isEqualTo: currentUser!.uid)
        .snapshots()
        .map(
      (snapshot) {
        final isPendingFriendRequest = snapshot.docs
            .any((doc) => doc[DocumentFieldNames.statusFriendRequest] == false);

        final isSuccessFriendRequest = snapshot.docs
            .any((doc) => doc[DocumentFieldNames.statusFriendRequest] == true);

        if (isPendingFriendRequest) {
          return false;
        } else if (isSuccessFriendRequest) {
          return true;
        } else {
          return null;
        }
      },
    ).listen((event) {
      receiverSubject.add(event);
    });
    return CombineLatestStream.combine2(
      senderSubject.stream,
      receiverSubject.stream,
      (senderResult, receiverResult) {
        if (senderResult == true || receiverResult == true) {
          return true;
        } else if (senderResult == false || receiverResult == false) {
          return false;
        } else {
          return null;
        }
      },
    );
  }

  Stream<List<FriendRequest>> getFriendRequests() {
    return friendRequestsCollections
        .where(DocumentFieldNames.receiverId, isEqualTo: currentUser!.uid)
        .where(DocumentFieldNames.statusFriendRequest, isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FriendRequest.formMap(doc.data()))
            .toList());
  }
}
