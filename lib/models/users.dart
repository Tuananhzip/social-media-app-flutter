import 'package:social_media_app/utils/field_names.dart';

class Users {
  String? email;
  String? username;
  String? imageProfile;
  String? address;
  String? phoneNumber;
  bool? gender;
  DateTime? dateOfBirth;
  String? description;

  Users({
    this.email,
    this.username,
    this.imageProfile,
    this.address,
    this.phoneNumber,
    this.gender,
    this.dateOfBirth,
    this.description,
  });
  @override
  String toString() {
    return 'Users {\n'
        '  ${DocumentFieldNames.email}: $email,\n'
        '  ${DocumentFieldNames.username}: $username,\n'
        '  ${DocumentFieldNames.imageProfile}: $imageProfile,\n'
        '  ${DocumentFieldNames.address}: $address,\n'
        '  ${DocumentFieldNames.phoneNumber}: $phoneNumber,\n'
        '  ${DocumentFieldNames.gender}: $gender,\n'
        '  ${DocumentFieldNames.dateOfBirth}: $dateOfBirth,\n'
        '  ${DocumentFieldNames.description}: $description\n'
        '}';
  }

  Users.formMap(Map map)
      : this(
          email: map[DocumentFieldNames.email],
          username: map[DocumentFieldNames.username],
          imageProfile: map[DocumentFieldNames.imageProfile],
          address: map[DocumentFieldNames.address],
          phoneNumber: map[DocumentFieldNames.phoneNumber],
          gender: map[DocumentFieldNames.gender],
          dateOfBirth: map[DocumentFieldNames.dateOfBirth] != null
              ? map[DocumentFieldNames.dateOfBirth].toDate()
              : map[DocumentFieldNames.dateOfBirth],
          description: map[DocumentFieldNames.description],
        );

  Map<String, dynamic> asMap() => {
        DocumentFieldNames.email: email,
        DocumentFieldNames.username: username,
        DocumentFieldNames.imageProfile: imageProfile,
        DocumentFieldNames.address: address,
        DocumentFieldNames.phoneNumber: phoneNumber,
        DocumentFieldNames.gender: gender,
        DocumentFieldNames.dateOfBirth: dateOfBirth,
        DocumentFieldNames.description: description,
      };
}
