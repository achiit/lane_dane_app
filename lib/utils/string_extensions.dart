extension StringUtilities on String {
  String capitalization() {
    return (this[0].toUpperCase() + substring(1));
  }

  String get phoneNumber {
    String phone = replaceAll(RegExp('[^0-9]'), '');
    if (phone.length >= 10) {
      phone = phone.substring(phone.length - 10);
    }
    return phone;
  }
}
