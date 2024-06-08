import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/models/messages.dart';
import 'package:social_media_app/utils/collection_names.dart';
import 'package:social_media_app/utils/field_names.dart';

class MessageServices {
  final _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  Future<void> sendMessage(String receiverId, String message) async {
    try {
      final currentUserId = _currentUser!.uid;
      final Timestamp timestamp = Timestamp.now();

      Messages newMessage = Messages(
        senderId: currentUserId,
        recipientId: receiverId,
        messageContent: message,
        messageCreatedTime: timestamp,
      );

      List<String> ids = [currentUserId, receiverId];
      ids.sort();
      String chatRoomId = ids.join("_");

      await _firestore
          .collection(FirestoreCollectionNames.chatRooms)
          .doc(chatRoomId)
          .collection(FirestoreCollectionNames.messages)
          .add(newMessage.asMap());
    } catch (e) {
      // ignore: avoid_print
      print('Error sending message sendMessage -----> : $e');
    }
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection(FirestoreCollectionNames.chatRooms)
        .doc(chatRoomId)
        .collection(FirestoreCollectionNames.messages)
        .orderBy(DocumentFieldNames.messageCreatedTime, descending: false)
        .snapshots();
  }
}
