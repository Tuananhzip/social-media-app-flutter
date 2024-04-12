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
        '  email: $email,\n'
        '  username: $username,\n'
        '  imageProfile: $imageProfile,\n'
        '  address: $address,\n'
        '  phoneNumber: $phoneNumber,\n'
        '  gender: $gender,\n'
        '  dateOfBirth: $dateOfBirth,\n'
        '  description: $description\n'
        '}';
  }

  Users.formMap(Map map)
      : this(
          email: map['email'],
          username: map['username'],
          imageProfile: map['imageProfile'],
          address: map['address'],
          phoneNumber: map['phoneNumber'],
          gender: map['gender'],
          dateOfBirth: map['dateOfBirth'],
          description: map['descriptiong'],
        );

  Map<String, dynamic> asMap() => {
        'email': email,
        'username': username,
        'imageProfile': imageProfile,
        'address': address,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
        'description': description,
      };
}
