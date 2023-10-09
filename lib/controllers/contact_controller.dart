import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:lane_dane/controllers/user_group_entity_controller.dart';
import 'package:lane_dane/controllers/users_controller.dart';
import 'package:lane_dane/models/user_group_entity.dart';
import 'package:lane_dane/objectbox.g.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:lane_dane/main.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/api/contact_services.dart';

extension FormatPhoneNumber on String {
  String get formattedPhoneNumber {
    String phone = replaceAll(RegExp('[^0-9]'), '');
    if (phone.length >= 10) {
      phone = phone.substring(phone.length - 10);
    } else if (phone.length <= 8) {
      phone = '91$phone';
    }
    return phone;
  }
}

extension FormattedPhoneNumber on Contact {
  String get formattedPhoneNumber {
    return phones[0].number.formattedPhoneNumber;
  }

  List<String> formattedPhoneNumberList() {
    return phones.map<String>((Phone phone) {
      return phone.number.formattedPhoneNumber;
    }).toList();
  }
}

class ContactController {
  static bool contactsStored = false;

  List<Users> nativeContacts = [];
  ContactServices contactServices = ContactServices();
  List<Users> differencesInContacts = [];
  List<Users> uniquelist = [];
  List<Users> differenceUsingContactName = [];

  late Map<String, dynamic> userData;
  final userBox = OBJECTBOX.store.box<Users>();
  final log = getLogger('ContactController');

  Future<void> storeNewContacts() async {
    List<Contact> newContactsList = await getNewContacts();
    List<Users> userList = await updateContactsOnBackend(newContactsList);
    userBox.putMany(userList);
  }

  Future<void> localStoreNewContacts() async {
    if (ContactController.contactsStored) {
      return;
    }
    List<Contact> newContactsList = await getNewContacts();
    UserHelper userHelper = UserHelper();
    OBJECTBOX.store.runInTransaction(TxMode.write, () {
      for (Contact contact in newContactsList) {
        List<String> phoneNumberList = contact.formattedPhoneNumberList();
        for (String phone in phoneNumberList) {
          Users user = userHelper.updateOrCreate(
            fullName: contact.displayName,
            phoneNumber: phone.formattedPhoneNumber,
          );
        }
      }
    });
    ContactController.contactsStored = true;
  }

  Future<List<Contact>> getNewContacts() async {
    List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true, withPhoto: true);
    log.d('${contacts.length} contacts fetched');

    Set<String> seen = <String>{};
    List<Contact> newContacts = contacts.where((contact) {
      if (contact.phones.isEmpty) {
        return false;
      }

      // * Duplication was added intentionally, because either of the 2 number of user can have whatsapp registered with it.  So, we need to show both numbers to user -> [ NEEDS TO BE FIXED IN FUTURE WITH A SOLUTION ]
      // if (!seen.add(contact.formattedPhoneNumber)) {
      //   return false; // This implies this number was already added to the set
      // }

      List<String> phoneNumberList = contact.formattedPhoneNumberList();
      bool needToAdd = false;
      for (String phone in phoneNumberList) {
        Users? user = UserHelper().retrieveUserFromPhoneNumber(phone);
        if (user == null) {
          needToAdd =
              true; // This implies that the user is already in objectbox
        }
      }
      return needToAdd;
    }).toList();

    return newContacts;
  }

  Future<List<Users>> updateContactsOnBackend(List<Contact> contactList) async {
    List<dynamic> userDetailsList =
        await contactServices.syncContacts(contactList);

    List<Users> userList = [];
    for (Map<dynamic, dynamic> userMap in userDetailsList) {
      try {
        userList.add(Users(
          phone_no: userMap['phone_no'].toString().formattedPhoneNumber,
          full_name: userMap['full_name'],
          id: userMap['id'],
          onBoardedAt: Users.startOfTime,
          tapCount: 0,
        ));
      } catch (err) {
        log.e(
            'Failed to add user: ${userMap['full_name']} -> ${userMap['phone_no']}');
        log.e(err.toString());
        log.e(userMap);
        continue;
      }
    }

    return userList;
  }
}
