import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/models/users.dart';

class UserServices {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final currentUser = FirebaseAuth.instance.currentUser;

  Stream<DocumentSnapshot> getUserStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .snapshots();
  }

  Future<Users?> fetchDataUserInfo() async {
    try {
      DocumentSnapshot userSnapshot =
          await usersCollection.doc(currentUser!.uid).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userDate = Users().asMap();
        Users user = Users.formMap(userDate);
        return user;
      } else {
        return null;
      }
    } catch (error) {
      // ignore: avoid_print
      print('Error fetching user data (fetchDataUserInfo): $error');
      return null;
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
}
