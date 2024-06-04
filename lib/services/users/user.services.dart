import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/utils/collection_names.dart';
import 'package:social_media_app/utils/field_names.dart';

class UserServices {
  final _usersCollection =
      FirebaseFirestore.instance.collection(FirestoreCollectionNames.users);
  final _currentUser = FirebaseAuth.instance.currentUser;

  Stream<DocumentSnapshot> getUserStream() {
    String uid = _currentUser!.uid;
    if (uid.isNotEmpty) {
      _createDocumentIfNotExists(uid);
    }
    return _usersCollection.doc(_currentUser.uid).snapshots();
  }

  Future<DocumentSnapshot> getUserEdit() async {
    String uid = _currentUser!.uid;
    return await _usersCollection.doc(uid).get();
  }

  Future<void> _createDocumentIfNotExists(String docId) async {
    try {
      DocumentReference docRef = _usersCollection.doc(docId);

      DocumentSnapshot docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        await docRef.set(<String, dynamic>{});
      }
      bool haveImagePhotoURL = _currentUser!.photoURL != null;
      bool notHaveImageProfile =
          docSnapshot[DocumentFieldNames.imageProfile] == null;
      if (haveImagePhotoURL && notHaveImageProfile) {
        await docRef.update({
          DocumentFieldNames.imageProfile: _currentUser.photoURL,
        });
      }
    } catch (error) {
      // ignore: avoid_print
      print("createDocumentIfNotExists ERROR ---> $error");
    }
  }

  Future<void> addAndEditProfileUser(Map<String, dynamic> userInfo) async {
    try {
      String uid = _currentUser!.uid;
      await _usersCollection.doc(uid).set(userInfo, SetOptions(merge: true));
    } catch (error) {
      // ignore: avoid_print
      print("addAndEditProfileUser Services ERROR ---> $error");
    }
  }

  Future<QuerySnapshot> getUsersOrderyByUsername() async {
    return await _usersCollection.orderBy(DocumentFieldNames.username).get();
  }

  Future<Users?> getUserDetailsByID(String documentID) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection(FirestoreCollectionNames.users)
        .doc(documentID)
        .get();
    if (docSnapshot.exists) {
      Map<String, dynamic> userData =
          docSnapshot.data() as Map<String, dynamic>;
      return Users.fromMap(userData);
    }
    return null;
  }

  Future<String?> getProfileImageByCurrentUser() async {
    try {
      DocumentSnapshot docSnapshot =
          await _usersCollection.doc(_currentUser!.uid).get();
      if (docSnapshot.exists) {
        return docSnapshot[DocumentFieldNames.imageProfile];
      }
    } catch (e) {
      // ignore: avoid_print
      print("getProfileImageByCurrentUser ERROR ---> $e");
    }
    return null;
  }
}
