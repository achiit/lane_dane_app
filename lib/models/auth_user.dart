class AuthUser {
  final int id;
  final String fullName;
  final String? fcmToken;
  final int phoneNo;
  final String otp;
  final DateTime otpExpiresAt;
  final DateTime onBoardedAt;
  final String? email;
  final String? profilePic;
  final String timezone;
  final String countryCode;
  final bool businessAccount;
  bool isPremium;
  final bool demoAccount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  AuthUser({
    required this.id,
    required this.fullName,
    this.fcmToken,
    required this.phoneNo,
    required this.otp,
    required this.otpExpiresAt,
    required this.onBoardedAt,
    this.email,
    this.profilePic,
    required this.timezone,
    required this.countryCode,
    required this.businessAccount,
    required this.isPremium,
    required this.demoAccount,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory AuthUser.fromMap(Map<String, dynamic> m) {
    return AuthUser(
      id: m['id'],
      fullName: m['full_name'],
      fcmToken: m['fcm_token'],
      phoneNo: m['phone_no'],
      otp: m['otp'],
      otpExpiresAt: DateTime.parse(m['otp_expires_at']),
      onBoardedAt: DateTime.parse(m['onboarded_at']),
      email: m['email'],
      profilePic: m['profile_pic'],
      timezone: m['timezone'],
      countryCode: m['country_code'],
      businessAccount: m['business_account'] == 1 ? true : false,
      isPremium: m['is_premium'] == 1 ? true : false,
      demoAccount: m['is_demo_account'] == 1 ? true : false,
      createdAt: DateTime.parse(m['created_at']),
      updatedAt: DateTime.parse(m['updated_at']),
      deletedAt:
          m['deleted_at'] != null ? DateTime.parse(m['deleted_at']) : null,
    );
  }

  /// Returns the phone number as is saved.
  String get phoneNumberRaw {
    return phoneNo.toString();
  }

  /// Returns the 10 digit phone number without country code.
  String get phoneNumber {
    String phone = phoneNumberRaw.replaceAll(RegExp('[^0-9]'), '');
    if (phone.length >= 10) {
      phone = phone.substring(phone.length - 10);
    }
    return phone;
  }

  /// Returns the phone number with the country code.
  String get phoneNumberWithCode {
    return '91$phoneNumber';
  }

  /// Returns the phone number with country code and proper format
  String get phoneNumberFormatted {
    return '+91 $phoneNumber';
  }
}
