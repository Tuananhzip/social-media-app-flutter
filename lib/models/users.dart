class Users {
  final String email;
  final String password;
  String? username;
  String? imageProfile;
  String? address;
  String? phoneNumber;
  bool? gender;
  DateTime? dateOfBirth;
  String? description;

  Users(
      {required this.email,
      required this.password,
      this.username,
      this.imageProfile,
      this.address,
      this.phoneNumber,
      this.gender,
      this.dateOfBirth,
      this.description});
}
