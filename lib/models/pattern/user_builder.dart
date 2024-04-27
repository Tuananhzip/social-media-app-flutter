import 'package:social_media_app/models/users.dart';

class UsersBuilder {
  String? _email;
  String? _username;
  String? _imageProfile;
  String? _address;
  String? _phoneNumber;
  bool? _gender;
  DateTime? _dateOfBirth;
  String? _description;

  UsersBuilder setEmail(String email) {
    _email = email;
    return this;
  }

  UsersBuilder setUsername(String username) {
    _username = username;
    return this;
  }

  UsersBuilder setImageProfile(String imageProfile) {
    _imageProfile = imageProfile;
    return this;
  }

  UsersBuilder setAddress(String address) {
    _address = address;
    return this;
  }

  UsersBuilder setPhoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber;
    return this;
  }

  UsersBuilder setGender(bool gender) {
    _gender = gender;
    return this;
  }

  UsersBuilder setDateOfBirth(DateTime dateOfBirth) {
    _dateOfBirth = dateOfBirth;
    return this;
  }

  UsersBuilder setDescription(String description) {
    _description = description;
    return this;
  }

  Users build() {
    return Users(
      email: _email,
      username: _username,
      imageProfile: _imageProfile,
      address: _address,
      phoneNumber: _phoneNumber,
      gender: _gender,
      dateOfBirth: _dateOfBirth,
      description: _description,
    );
  }
}
