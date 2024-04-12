import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageServices {
  Future<String> uploadImageToStorage(File file) async {
    String url = '';
    String fileName = DateTime.now().microsecondsSinceEpoch.toString();

    Reference ref = FirebaseStorage.instance.ref();
    Reference refImage = ref.child('images_profile');
    Reference refImageToUpLoad = refImage.child(fileName);

    await refImageToUpLoad.putFile(file);

    url = await refImageToUpLoad.getDownloadURL();
    return url;
  }

  Future<void> updateProfileImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;

    String url = await uploadImageToStorage(File(file.path));

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      final userCollection = FirebaseFirestore.instance.collection('users');
      await userCollection.doc(uid).set(
        {'imageProfile': url},
        SetOptions(merge: true),
      );
    }
  }
}
