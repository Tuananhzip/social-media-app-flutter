import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageServices {
  final userCollection = FirebaseFirestore.instance.collection('users');
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<String> uploadImageToStorage(File file) async {
    String url = '';
    try {
      String fileName =
          '${FirebaseAuth.instance.currentUser!.email}-${DateTime.now().microsecondsSinceEpoch}';

      Reference ref = FirebaseStorage.instance.ref();
      Reference refImage = ref.child('images_profile');
      Reference refImageToUpLoad = refImage.child(fileName);

      await refImageToUpLoad.putFile(file);

      url = await refImageToUpLoad.getDownloadURL();
      return url;
    } catch (error) {
      // ignore: avoid_print
      print("uploadImageToStorage ERROR ---> $error");
      return url;
    }
  }

  Future<void> updateImageProfile() async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file == null) return;

      String url = await uploadImageToStorage(File(file.path));

      if (currentUser != null) {
        String uid = currentUser!.uid;
        final userDoc = await userCollection.doc(uid).get();
        if (userDoc.exists &&
            userDoc.data()!.containsKey('imageProfile') &&
            userDoc.data()!['imageProfile'] != null) {
          String oldImageUrl = userDoc.data()!['imageProfile'];
          await FirebaseStorage.instance.refFromURL(oldImageUrl).delete();
        }

        await userCollection.doc(uid).set(
          {'imageProfile': url},
          SetOptions(merge: true),
        );
      }
    } catch (error) {
      // ignore: avoid_print
      print("updateProfileImage ERROR ---> $error");
    }
  }

  Future<String?> getImageFromFirestore() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();
      if (snapshot.exists) {
        final data = snapshot.data();
        return data?['imageProfile'];
      } else {
        // ignore: avoid_print
        print('Document does not exist');
        return null;
      }
    } catch (error) {
      // ignore: avoid_print
      print("getImageFromFirestore ERROR ---> $error");
      return null;
    }
  }
}
