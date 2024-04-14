import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserServices {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final currentUser = FirebaseAuth.instance.currentUser;

  Stream<DocumentSnapshot> getUserStream() {
    String uid = currentUser!.uid;
    if (uid.isNotEmpty) {
      createDocumentIfNotExists(uid);
    }
    return usersCollection.doc(currentUser!.uid).snapshots();
  }

  Future<DocumentSnapshot> getUserFuture() async {
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

  Future<void> addAndEditProfileUser(
      String uid, Map<String, dynamic> userInfo) async {
    try {
      await usersCollection.doc(uid).set(userInfo, SetOptions(merge: true));
    } catch (error) {
      // ignore: avoid_print
      print("addAndEditProfileUser Services ERROR ---> $error");
    }
  }

  Stream<QuerySnapshot> getUsernameStream(String searchQuery) {
    return usersCollection
        .where('username', isGreaterThanOrEqualTo: searchQuery)
        .where('username', isLessThanOrEqualTo: searchQuery + '\uf7ff')
        .snapshots();
  }
}
