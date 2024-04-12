import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/screens/components/field/field_edit_profile.dart';
import 'package:social_media_app/serviecs/Users/user_services.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final UserServices userService = UserServices();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  String urlImage = '';

  Future<void> pickerImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    String fileName = DateTime.now().microsecondsSinceEpoch.toString();

    Reference ref = FirebaseStorage.instance.ref();
    Reference refImage = ref.child('images_profile');
    Reference referenceImageToUpload = refImage.child(fileName);

    try {
      await referenceImageToUpload.putFile(File(file.path));
      urlImage = await referenceImageToUpload.getDownloadURL();

      final collection = FirebaseFirestore.instance.collection('users');
      final docUser =
          await collection.where('email', isEqualTo: currentUser?.email).get();
      print(docUser.docs);
      print(urlImage);
    } catch (error) {
      print("pickerImage ---> $error");
    }
  }

  Future<void> saveUserInfo() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String email = currentUser!.email!;
    String username = usernameController.text.trim();
    String address = addressController.text.trim();
    String phoneNumber = phoneNumberController.text.trim();
    bool gender = false;
    String dateOfBirth = dateOfBirthController.text.trim();
    String description = descriptionController.text.trim();
    Map<String, dynamic> userInfo = Users(
      email: email,
      username: username,
      address: address,
      phoneNumber: phoneNumber,
      gender: gender,
      dateOfBirth: DateTime.now(),
      description: description,
    ).asMap();
    try {
      await userService.addAndEditProfileUser(uid, userInfo);
      print('User info saved successfully! $userInfo');
    } catch (error) {
      print('Update Profile User ERROR : ---> $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        margin: const EdgeInsets.all(16.0),
        color: Theme.of(context).colorScheme.background,
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            GestureDetector(
              onTap: pickerImage,
              child: Column(
                children: [
                  SizedBox(
                    width: 70.0,
                    height: 70.0,
                    child: CircleAvatar(
                      radius: 30.0,
                      backgroundImage: currentUser?.photoURL != null
                          ? NetworkImage(currentUser!.photoURL!)
                          : const NetworkImage(
                              "https://theatrepugetsound.org/wp-content/uploads/2023/06/Single-Person-Icon.png",
                            ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Edit picture",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(
                  width: 120.0,
                  child: Text("Username"),
                ),
                Expanded(
                  child: FieldEditProfile(controller: usernameController),
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(
                  width: 120.0,
                  child: Text("Address"),
                ),
                Expanded(
                  child: FieldEditProfile(controller: addressController),
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(
                  width: 120.0,
                  child: Text("Phone number"),
                ),
                Expanded(
                  child: FieldEditProfile(controller: phoneNumberController),
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(
                  width: 120.0,
                  child: Text("Gender"),
                ),
                Expanded(
                  child: FieldEditProfile(controller: genderController),
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(
                  width: 120.0,
                  child: Text("Date of birth"),
                ),
                Expanded(
                  child: FieldEditProfile(controller: dateOfBirthController),
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(
                  width: 120.0,
                  child: Text("Description"),
                ),
                Expanded(
                  child: FieldEditProfile(controller: descriptionController),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
