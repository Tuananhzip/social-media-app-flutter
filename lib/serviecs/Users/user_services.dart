import 'package:cloud_firestore/cloud_firestore.dart';

class UserServices {
  Future addUserEmail(String uid, String email) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'email': email});
  }
}
