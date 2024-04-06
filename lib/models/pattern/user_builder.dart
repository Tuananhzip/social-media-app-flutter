import 'package:social_media_app/models/Users.dart';
import 'package:social_media_app/models/pattern/builder.dart';

class UsersBuilder implements Builder<Users> {
  Users user;

  UsersBuilder({
    required String username,
    required String email,
    required String password,
  }) : user = Users(username: username, email: email, password: password);

  @override
  Users build() {
    return user;
  }

  @override
  Users reset() {
    return user = Users(
      username: '',
      email: '',
      password: '',
      address: '',
      dateOfBirth: null,
      description: '',
      gender: null,
      imageProfile: '',
      phoneNumber: '',
    );
  }

  @override
  UsersBuilder setImageProfile(String? imageProfile) {
    user.imageProfile = imageProfile;
    return this;
  }

  @override
  UsersBuilder setAddress(String? address) {
    user.address = address;
    return this;
  }

  @override
  UsersBuilder setPhoneNumber(String? phoneNumber) {
    user.phoneNumber = phoneNumber;
    return this;
  }

  @override
  UsersBuilder setGender(bool? gender) {
    user.gender = gender;
    return this;
  }

  @override
  UsersBuilder setDateOfBirth(DateTime? dateOfBirth) {
    user.dateOfBirth = dateOfBirth;
    return this;
  }

  @override
  UsersBuilder setDescription(String? description) {
    user.description = description;
    return this;
  }

  @override
  setUsername(String username) {
    user.username = username;
    return this;
  }
}
