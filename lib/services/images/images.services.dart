import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/utils/collection_names.dart';
import 'package:social_media_app/utils/field_names.dart';
import 'package:social_media_app/utils/my_enum.dart';

class ImageServices {
  final userCollection =
      FirebaseFirestore.instance.collection(FirestoreCollectionNames.users);
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<String> uploadImageToStorage(File file) async {
    String url = '';
    try {
      String fileName =
          '${FirebaseAuth.instance.currentUser!.email}-${DateTime.now().microsecondsSinceEpoch}';

      Reference ref = FirebaseStorage.instance.ref();
      Reference refImage = ref.child(DocumentFieldNames.imageProfile);
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
            userDoc.data()!.containsKey(DocumentFieldNames.imageProfile) &&
            userDoc.data()![DocumentFieldNames.imageProfile] != null) {
          String oldImageUrl = userDoc.data()![DocumentFieldNames.imageProfile];
          await FirebaseStorage.instance.refFromURL(oldImageUrl).delete();
        }

        await userCollection.doc(uid).set(
          {DocumentFieldNames.imageProfile: url},
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
              .collection(FirestoreCollectionNames.users)
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();
      if (snapshot.exists) {
        final data = snapshot.data();
        return data?[DocumentFieldNames.imageProfile];
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

  Future<List<File?>> pickMedia() async {
    final picker = ImagePicker();
    final pickedMedia = await picker.pickMultipleMedia();
    if (pickedMedia.isNotEmpty) {
      List<File> files = pickedMedia.map((file) => File(file.path)).toList();
      return files;
    }
    return [];
  }

  Future<File?> pickWithCamera(MediaType type) async {
    final picker = ImagePicker();
    XFile? pickedWithCamera;
    if (type == MediaType.image) {
      pickedWithCamera = await picker.pickImage(source: ImageSource.camera);
    } else if (type == MediaType.video) {
      pickedWithCamera = await picker.pickVideo(source: ImageSource.camera);
    }
    if (pickedWithCamera != null) {
      return File(pickedWithCamera.path);
    }
    return null;
  }
}
