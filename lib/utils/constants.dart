/// -> Connstant domain for the http request

// ignore_for_file: constant_identifier_names

class Constants {
// const String DOMAIN = 'http://192.168.0.12:3363';
// const String host = 'http://localhost:8000';
// String domain = 'http://172.20.10.2:3363';

//* @suhailbilalo Local IP
// String host = 'http://192.168.100.32:8000';

//* Main Server
  static String host = 'lane-dane.com';

//* @Abood2284 Local IP
// String host = 'http://192.168.0.12:8080';

// *@abdulaziz local IP
  // static String host = 'localhost:8000';

  /// Make this false when running on a local server. Otherwise true when running
  /// on main server.
  static bool get defaultToHttps {
    if (Constants.host == 'lane-dane.com') {
      return true;
    } else {
      return false;
    }
  }

  /// -> Constant variable for SMS BANK SENDER

  static String routeToPrivacyPolicy = 'privacy-policy';
  static String routeToTermsOfServices = 'term-of-services';

  static String CANARA_BANK = "AX-CANBNK";
  static String ICICIC_BANK = "VM-ICICIB";
  static String HDFC_BANK = "AM-HDFCBK";
  static String SBI_BANK =
      "BZ-SBIINB"; // TODO: Look for sbiiinb in sender name instead of static BZ

// REGEXP Used
  static String REGEXP_AMOUNT =
      r"(Rs|rs|INR).[\d,.]*\b"; // TODO: Get this Regexp implemented & working (Rs|rs|INR).[\d,.]*\b

  /// Checks that account number starts with a whitepsace character.
  /// Then checks that the first few characters are X.
  /// This should be followed by 2-5 digits.
  // static String REGEXP_ACCOUNTNUMBER = r"([X\*]+|(\.\.)+)\d{2,5}";
  static String REGEXP_ACCOUNTNUMBER = r"\s(X+\d{2,5})";
  // ! Replaced on  29 Jan 2023
  //  r"([Xx\*]+|(\.\.)+)\d{2,5}";
// const String REGEXP_DATE =
// r"(\d+\s*(\-|\/)\s*(\w+|\d+)\s*(\-|\/)\s*(\d+)\s*(\d*\:\d+\:\d+)*)";

  static String appLink =
      'https://play.google.com/store/apps/details?id=com.lane_dane.lane_dane';
  static String whatsappCustomerSupportGroup =
      'https://chat.whatsapp.com/DPJyhAlihvOEBUmTjbDIBb';
}
