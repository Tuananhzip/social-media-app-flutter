import 'package:cloud_firestore/cloud_firestore.dart';

class UserServices {
  Future addUserEmail(String email) async {
    await FirebaseFirestore.instance.collection('users').add({'email': email});
  }
}
