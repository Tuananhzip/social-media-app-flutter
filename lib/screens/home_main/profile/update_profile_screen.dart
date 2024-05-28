import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:social_media_app/components/loading/loading_flickr.component.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/components/button/radio_button_gender.component.dart';
import 'package:social_media_app/components/field/field_edit_profile.component.dart';
import 'package:social_media_app/services/images/images.services.dart';
import 'package:social_media_app/services/users/user.services.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/my_enum.dart';
import 'package:social_media_app/utils/notifications_dialog.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final _formKey = GlobalKey<FormState>();
  final UserServices _userService = UserServices();
  final ImageServices _imageService = ImageServices();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _currentUser = FirebaseAuth.instance.currentUser;
  String? _urlImage;
  Users _user = Users();
  Genders? _genders = Genders.male;

  @override
  initState() {
    super.initState();
    getUserEdit();
  }

  Future<void> getUserEdit() async {
    try {
      final data = await _userService.getUserEdit();
      Map<String, dynamic> userData = data.data() as Map<String, dynamic>;
      _user = Users.fromMap(userData);

      _usernameController.text = _user.username ?? '';
      _addressController.text = _user.address ?? '';
      _phoneNumberController.text = _user.phoneNumber ?? '';
      _genderController.text = _user.gender.toString();
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      final String dateNew = _user.dateOfBirth != null
          ? dateFormat.format(_user.dateOfBirth!)
          : '';
      _dateOfBirthController.text = dateNew;
      _descriptionController.text = _user.description ?? '';
      setState(() {
        _urlImage = _user.imageProfile;
      });
    } catch (error) {
      // ignore: avoid_print
      print("getUserEdit :---> $error");
    }
  }

  Future<void> updateImageProfile() async {
    context.loaderOverlay
        .show(widgetBuilder: (_) => const LoadingFlickrComponent());
    try {
      await _imageService.updateImageProfile();
    } catch (error) {
      // ignore: avoid_print
      print("Update Image Profile User ERROR (updateImageProfile) ---> $error");
    } finally {
      final dataImage = await _imageService.getImageFromFirestore();
      setState(() {
        _urlImage = dataImage ?? _user.imageProfile;
      });
    }
    // ignore: use_build_context_synchronously
    context.loaderOverlay.hide();
  }

  Future<void> saveUserInfo() async {
    context.loaderOverlay.show(
      widgetBuilder: (progress) => const LoadingFlickrComponent(),
    );
    final bool isValidation = _formKey.currentState!.validate();
    if (!isValidation) {
      context.loaderOverlay.hide();
      return;
    }
    try {
      final String email = _currentUser!.email!;
      final String username = _usernameController.text.trim();
      final String address = _addressController.text.trim();
      final String phoneNumber = _phoneNumberController.text.trim();
      // Male (true) || Female (false) || Empty (null)
      final bool? gender = _genders == Genders.female
          ? false
          : _genders == Genders.male
              ? true
              : _genders = null;
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      final DateTime dateNew = dateFormat.parse(_dateOfBirthController.text);
      final DateTime dateOfBirthUpdate = dateNew;
      final String description = _descriptionController.text.trim();
      final String? imageProfile = _urlImage;
      setState(() {
        _urlImage = imageProfile ?? _user.imageProfile;
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

      await _userService.addAndEditProfileUser(userInfo);
      // ignore: avoid_print
      print('User info saved successfully! ---> $userInfo');
      DialogNotifications.notificationSuccess(
        // ignore: use_build_context_synchronously
        context,
        "Update Success",
        "Your profile has been updated",
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (error) {
      // ignore: avoid_print
      print('ERROR (saveUserInfo) ---> $error');
    } finally {
      // ignore: use_build_context_synchronously
      context.loaderOverlay.hide();
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
        _dateOfBirthController.text = picked.toString().split(" ")[0];
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
            key: _formKey,
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
                            backgroundImage: _urlImage != null &&
                                    _urlImage != ''
                                ? NetworkImage(_urlImage!)
                                : _currentUser!.photoURL != null
                                    ? NetworkImage(_currentUser.photoURL!)
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
                        child: FieldEditProfileComponent(
                          controller: _usernameController,
                          textInputType: TextInputType.multiline,
                          validation: (_) =>
                              validateUsername(_usernameController.text),
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
                        child: FieldEditProfileComponent(
                          controller: _addressController,
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
                        child: FieldEditProfileComponent(
                          controller: _phoneNumberController,
                          textInputType: TextInputType.phone,
                          validation: (_) =>
                              validatePhoneNumber(_phoneNumberController.text),
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
                          child: RadioButtonWidgetComponent(
                        groupValue: _genders,
                        onChanged: (Genders? value) {
                          setState(() {
                            _genders = value;
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
                        child: FieldEditProfileComponent(
                          controller: _dateOfBirthController,
                          readOnly: true,
                          onTap: selectDate,
                          textInputType: TextInputType.datetime,
                          validation: (_) =>
                              validateDateOfBirth(_dateOfBirthController.text),
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
                        child: FieldEditProfileComponent(
                          controller: _descriptionController,
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
