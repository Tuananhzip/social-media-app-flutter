abstract class Builder<T> {
  reset();
  T build();
  setUsername(String username);
  setImageProfile(String imageProfile);
  setAddress(String address);
  setPhoneNumber(String phoneNumber);
  setGender(bool gender);
  setDateOfBirth(DateTime dateOfBirth);
  setDescription(String description);
}
