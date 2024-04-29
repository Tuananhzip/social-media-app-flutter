import 'package:social_media_app/utils/field_names.dart';

class Users {
  final String? _email;
  final String? _username;
  final String? _imageProfile;
  final String? _address;
  final String? _phoneNumber;
  final bool? _gender;
  final DateTime? _dateOfBirth;
  final String? _description;

  Users({
    String? email,
    String? username,
    String? imageProfile,
    String? address,
    String? phoneNumber,
    bool? gender,
    DateTime? dateOfBirth,
    String? description,
  })  : _email = email,
        _username = username,
        _imageProfile = imageProfile,
        _address = address,
        _phoneNumber = phoneNumber,
        _gender = gender,
        _dateOfBirth = dateOfBirth,
        _description = description;

  String? get email => _email;
  String? get username => _username;
  String? get imageProfile => _imageProfile;
  String? get address => _address;
  String? get phoneNumber => _phoneNumber;
  bool? get gender => _gender;
  DateTime? get dateOfBirth => _dateOfBirth;
  String? get description => _description;

  @override
  String toString() {
    return 'Users {\n'
        '  ${DocumentFieldNames.email}: $_email,\n'
        '  ${DocumentFieldNames.username}: $_username,\n'
        '  ${DocumentFieldNames.imageProfile}: $_imageProfile,\n'
        '  ${DocumentFieldNames.address}: $_address,\n'
        '  ${DocumentFieldNames.phoneNumber}: $_phoneNumber,\n'
        '  ${DocumentFieldNames.gender}: $_gender,\n'
        '  ${DocumentFieldNames.dateOfBirth}: $_dateOfBirth,\n'
        '  ${DocumentFieldNames.description}: $_description\n'
        '}';
  }

  factory Users.fromMap(Map map) {
    return Users(
      email: map[DocumentFieldNames.email],
      username: map[DocumentFieldNames.username],
      imageProfile: map[DocumentFieldNames.imageProfile],
      address: map[DocumentFieldNames.address],
      phoneNumber: map[DocumentFieldNames.phoneNumber],
      gender: map[DocumentFieldNames.gender],
      dateOfBirth: map[DocumentFieldNames.dateOfBirth]?.toDate(),
      description: map[DocumentFieldNames.description],
    );
  }

  Map<String, dynamic> asMap() => {
        DocumentFieldNames.email: _email,
        DocumentFieldNames.username: _username,
        DocumentFieldNames.imageProfile: _imageProfile,
        DocumentFieldNames.address: _address,
        DocumentFieldNames.phoneNumber: _phoneNumber,
        DocumentFieldNames.gender: _gender,
        DocumentFieldNames.dateOfBirth: _dateOfBirth,
        DocumentFieldNames.description: _description,
      };
}
