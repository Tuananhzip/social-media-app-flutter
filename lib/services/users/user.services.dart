import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/utils/collection_names.dart';
import 'package:social_media_app/utils/field_names.dart';

class UserServices {
  final usersCollection =
      FirebaseFirestore.instance.collection(FirestoreCollectionNames.users);
  final currentUser = FirebaseAuth.instance.currentUser;

  Stream<DocumentSnapshot> getUserStream() {
    String uid = currentUser!.uid;
    if (uid.isNotEmpty) {
      createDocumentIfNotExists(uid);
    }
    return usersCollection.doc(currentUser!.uid).snapshots();
  }

  Future<DocumentSnapshot> getUserEdit() async {
    String uid = currentUser!.uid;
    return await usersCollection.doc(uid).get();
  }

  Future<void> createDocumentIfNotExists(String docId) async {
    try {
      DocumentReference docRef = usersCollection.doc(docId);

      DocumentSnapshot docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        await docRef.set(<String, dynamic>{});
      }
    } catch (error) {
      // ignore: avoid_print
      print("createDocumentIfNotExists ERROR ---> $error");
    }
  }

  Future<void> addAndEditProfileUser(Map<String, dynamic> userInfo) async {
    try {
      String uid = currentUser!.uid;
      await usersCollection.doc(uid).set(userInfo, SetOptions(merge: true));
    } catch (error) {
      // ignore: avoid_print
      print("addAndEditProfileUser Services ERROR ---> $error");
    }
  }

  Stream<QuerySnapshot> getUsernameStream(String searchQuery) {
    return usersCollection
        .where(DocumentFieldNames.username, isGreaterThanOrEqualTo: searchQuery)
        .where(DocumentFieldNames.username,
            isLessThanOrEqualTo: '$searchQuery\uf7ff')
        .snapshots()
        .debounceTime(const Duration(milliseconds: 500));
  }

  Future<Users?> getUserDetailsByID(String documentID) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection(FirestoreCollectionNames.users)
        .doc(documentID)
        .get();
    if (docSnapshot.exists) {
      Map<String, dynamic> userData =
          docSnapshot.data() as Map<String, dynamic>;
      return Users.formMap(userData);
    }
    return null;
  }
}
