import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/utils/collection_names.dart';
import 'package:social_media_app/utils/field_names.dart';
import 'package:social_media_app/utils/my_enum.dart';

class ImageServices {
  final _userCollection =
      FirebaseFirestore.instance.collection(FirestoreCollectionNames.users);
  final _currentUser = FirebaseAuth.instance.currentUser;

  Future<String> uploadImageToStorage(File file) async {
    String url = '';
    try {
      String fileName =
          '${_currentUser!.email}-${DateTime.now().microsecondsSinceEpoch}.jpg';

      Reference ref = FirebaseStorage.instance.ref();
      Reference refImage = ref.child(DocumentFieldNames.imageProfile);
      Reference refImageToUpLoad = refImage.child(fileName);

      await refImageToUpLoad.putFile(file);

      url = await refImageToUpLoad.getDownloadURL();
      return url;
    } catch (error) {
      // ignore: avoid_print
      print("uploadImageToStorage ERROR ---> $error");
    }
    return url;
  }

  Future<void> updateImageProfile() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (file == null) return;

      String url = await uploadImageToStorage(File(file.path));

      if (_currentUser != null) {
        String uid = _currentUser.uid;
        final userDoc = await _userCollection.doc(uid).get();
        if (userDoc.exists &&
            userDoc.data()!.containsKey(DocumentFieldNames.imageProfile) &&
            userDoc.data()![DocumentFieldNames.imageProfile] != null) {
          String oldImageUrl = userDoc.data()![DocumentFieldNames.imageProfile];
          await FirebaseStorage.instance.refFromURL(oldImageUrl).delete();
        }

        await _userCollection.doc(uid).set(
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
    final pickedMedia = await picker.pickMultipleMedia(
      imageQuality: 100,
    );
    List<File> files = [];
    if (pickedMedia.isNotEmpty) {
      for (var media in pickedMedia) {
        files.add(File(media.path));
      }
      return files;
    }
    return [];
  }

  Future<File?> pickWithCamera(MediaTypeEnum type) async {
    final picker = ImagePicker();
    XFile? pickedWithCamera;
    if (type == MediaTypeEnum.image) {
      pickedWithCamera = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );
    } else if (type == MediaTypeEnum.video) {
      pickedWithCamera = await picker.pickVideo(
        source: ImageSource.camera,
      );
    }
    if (pickedWithCamera != null) {
      return File(pickedWithCamera.path);
    }
    return null;
  }

  Future<File?> compressImage(File file) async {
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final targetPath = "${splitted}_out${filePath.substring(lastIndex)}";
    final compressImage = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 50,
      minHeight: 1920,
      minWidth: 1080,
    );
    if (compressImage != null) {
      // ignore: avoid_print
      print("Original Image ---> ${file.lengthSync()}");
      // ignore: avoid_print
      print("Compress Image ---> ${File(compressImage.path).lengthSync()}");
      return File(compressImage.path);
    }
    return null;
  }
}
