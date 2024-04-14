import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/components/button/radio_button_gender.dart';
import 'package:social_media_app/components/field/field_edit_profile.dart';
import 'package:social_media_app/components/loading/overlay_loading.dart';
import 'package:social_media_app/serviecs/Images/images_services.dart';
import 'package:social_media_app/serviecs/Users/user_services.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/my_enum.dart';
import 'package:social_media_app/utils/notifications_dialog.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final formKey = GlobalKey<FormState>();
  final UserServices userService = UserServices();
  final ImageServices imageService = ImageServices();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  String? urlImage;
  Users user = Users();
  String? dateOfBirthNew = '';
  Genders? genders = Genders.male;

  @override
  initState() {
    super.initState();
    getUserEdit();
  }

  Future<void> getUserEdit() async {
    try {
      final data = await userService.getUserFuture();
      Map<String, dynamic> userData = data.data() as Map<String, dynamic>;
      user = Users.formMap(userData);

      usernameController.text = user.username ?? '';
      addressController.text = user.address ?? '';
      phoneNumberController.text = user.phoneNumber ?? '';
      genderController.text = user.gender.toString();
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      final String dateNew =
          user.dateOfBirth != null ? dateFormat.format(user.dateOfBirth!) : '';
      dateOfBirthController.text = dateNew;
      descriptionController.text = user.description ?? '';
      setState(() {
        urlImage = user.imageProfile ?? '';
      });
    } catch (error) {
      print("getUserEdit :---> $error");
    }
    // ignore: avoid_print
    //print(user);
  }

  Future<void> updateImageProfile() async {
    context.loaderOverlay
        .show(widgetBuilder: (_) => const OverlayLoadingWidget());
    try {
      await imageService.updateImageProfile();
    } catch (error) {
      // ignore: avoid_print
      print("Update Image Profile User ERROR (updateImageProfile) ---> $error");
    } finally {
      // ignore: use_build_context_synchronously
      final dataImage = await imageService.getImageFromFirestore();
      setState(() {
        urlImage = dataImage ?? user.imageProfile;
      });
      // ignore: use_build_context_synchronously
      context.loaderOverlay.hide();
    }
  }

  Future<void> saveUserInfo() async {
    context.loaderOverlay.show(
      widgetBuilder: (progress) => const OverlayLoadingWidget(),
    );
    final bool isValidation = formKey.currentState!.validate();
    if (!isValidation) return;
    try {
      final String uid = currentUser!.uid;
      final String email = currentUser!.email!;
      final String username = usernameController.text.trim();
      final String address = addressController.text.trim();
      final String phoneNumber = phoneNumberController.text.trim();
      // Male (true) || Female (false) || Empty (null)
      final bool? gender = genders == Genders.female
          ? false
          : genders == Genders.male
              ? true
              : genders = null;
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      final DateTime dateNew = dateFormat.parse(dateOfBirthController.text);
      final DateTime dateOfBirthUpdate = dateNew;
      final String description = descriptionController.text.trim();
      final String? imageProfile = urlImage;
      setState(() {
        urlImage = imageProfile ?? user.imageProfile;
      });
      Map<String, dynamic> userInfo = Users(
        email: email,
        username: username,
        address: address,
        phoneNumber: phoneNumber,
        gender: gender,
        dateOfBirth: dateOfBirthUpdate,
        description: description,
        imageProfile: imageProfile,
      ).asMap();

      await userService.addAndEditProfileUser(uid, userInfo);
      // ignore: avoid_print
      print('User info saved successfully! ---> $userInfo');
      DialogNotifications.notificationSuccess(
        // ignore: use_build_context_synchronously
        context,
        "Update Success",
        "Your profile has been updated",
      );
      // ignore: use_build_context_synchronously
      context.loaderOverlay.hide();
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (error) {
      // ignore: avoid_print
      print('ERROR (saveUserInfo) ---> $error');
    }
  }

  Future<void> selectDate() async {
    final DateTime currentDate = DateTime.now();
    final DateTime minimumDate =
        DateTime(currentDate.year - 16, currentDate.month, currentDate.day);
    final DateTime maximumDate =
        DateTime(currentDate.year - 100, currentDate.month, currentDate.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: minimumDate,
      firstDate: maximumDate,
      lastDate: minimumDate,
    );
    if (picked != null && picked != currentDate) {
      setState(() {
        dateOfBirthController.text = picked.toString().split(" ")[0];
      });
    }
  }

  String? validatePhoneNumber(String value) {
    String pattern = r'^(\+84|0)+([0-9]{9})$';
    final RegExp regExp = RegExp(pattern);
    if (value.isEmpty || value == '') {
      return 'Please enter phone number';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter valid phone number (+84 or 10 number)';
    }
    return null;
  }

  String? validateUsername(String value) {
    if (value.isEmpty || value == '') {
      return 'Please enter your username';
    }
    return null;
  }

  String? validateDateOfBirth(String value) {
    if (value.isEmpty || value == '') {
      return 'Please enter your date of birth';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Edit profile",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: GestureDetector(
                onTap: saveUserInfo,
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.successColor,
                  size: 32.0,
                ),
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Container(
              margin: const EdgeInsets.all(16.0),
              color: Theme.of(context).colorScheme.background,
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: updateImageProfile,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 100.0,
                          height: 100.0,
                          child: CircleAvatar(
                            radius: 30.0,
                            backgroundImage: urlImage != null && urlImage != ''
                                ? NetworkImage(urlImage!)
                                : currentUser!.photoURL != null
                                    ? NetworkImage(currentUser!.photoURL!)
                                    : const NetworkImage(
                                        "https://theatrepugetsound.org/wp-content/uploads/2023/06/Single-Person-Icon.png"),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 120.0,
                        child: Text(
                          "Username",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: FieldEditProfile(
                          controller: usernameController,
                          textInputType: TextInputType.multiline,
                          validation: (_) =>
                              validateUsername(usernameController.text),
                        ),
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 120.0,
                        child: Text(
                          "Address",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: FieldEditProfile(
                          controller: addressController,
                          textInputType: TextInputType.streetAddress,
                        ),
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 120.0,
                        child: Text(
                          "Phone number",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: FieldEditProfile(
                          controller: phoneNumberController,
                          textInputType: TextInputType.phone,
                          validation: (_) =>
                              validatePhoneNumber(phoneNumberController.text),
                        ),
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 120.0,
                        child: Text(
                          "Gender",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                          child: RadioButtonWidget(
                        groupValue: genders,
                        onChanged: (Genders? value) {
                          setState(() {
                            genders = value;
                          });
                        },
                      ))
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 120.0,
                        child: Text(
                          "Date of birth",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: FieldEditProfile(
                          controller: dateOfBirthController,
                          readOnly: true,
                          onTap: selectDate,
                          textInputType: TextInputType.datetime,
                          validation: (_) =>
                              validateDateOfBirth(dateOfBirthController.text),
                        ),
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 120.0,
                        child: Text(
                          "Description",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: FieldEditProfile(
                          controller: descriptionController,
                          textInputType: TextInputType.text,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
