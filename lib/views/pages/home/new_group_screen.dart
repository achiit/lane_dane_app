// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

import '../../../utils/log_printer.dart';
import '../../../models/group_users_model.dart';
import '../../../api/contact_services.dart';
import '../../shared/snack-bar.dart';
import '../../widgets/groupSelectContact.dart';

class NewGroupScreen extends StatefulWidget {
  static const String routeName = '/NewGroupScreen';
  final int id;
  const NewGroupScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  List<int> selectedIDs = [];
  late List<bool> isSelected;
  final log = getLogger('NewGroup');
  ContactServices contactServices = ContactServices();

  // List<UserContacts>? userModelsFromBackend;

  // final List<UserContacts> _usersFromSqlLocalDataBase = [];

  // final contactsSqfLiteHelper = ContactsSqfLiteHelper();
  // final groupUserSQLHElper = GroupUserSqlliteHelper.instance;

  @override
  void initState() {
    selectedIDs = [];
    super.initState();
    fetchDataFromSql();

    // fetchNativeContacts();
    // fetchContactsFromBackend();
  }

  // late int _id;
  Future<void> addToGroupUserSql(Map<String, dynamic> data) async {
    // await groupUserSQLHElper.create();
    // _id = await groupUserSQLHElper.insert(data);
  }

  Future<void> fetchDataFromSql() async {
    // _usersFromSqlLocalDataBase =
    // await contactsSqfLiteHelper.fetchContactsFromSql();
    // isSelected = List.filled(_usersFromSqlLocalDataBase.length, false);
    // setState(() {});
    // for (var i = 0; i < _usersFromSqlLocalDataBase.length; i++) {
    //   // log.i(_usersFromSqlLocalDataBase[i].toJson());
    // }
    // await FirebaseCrashlytics.instance.recordError(
    //     'Contacts From Local in Select Contact ${_usersFromSqlLocalDataBase.length}',
    //     null,
    //     reason: 'a non-fatal error');
    // FirebaseCrashlytics.instance.log(
    //     'We found ${_usersFromSqlLocalDataBase.length} Contacts from your local Database');
    // log.d('${_usersFromSqlLocalDataBase.length} contacts fetched from sql');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //leading icon for previous screen will automatically
        //once this screen is added

        backgroundColor: const Color(0xff008069),
        title: const ListTile(
          minLeadingWidth: 0,
          title: Text(
            'New Group',
            style: TextStyle(color: Colors.white, fontSize: 23),
          ),
          subtitle: Text(
            'Add participant',
            style: TextStyle(color: Colors.white),
          ),
          trailing: Icon(
            Icons.search,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchDataFromSql,
        child: Padding(
          padding: const EdgeInsets.only(top: 15, left: 5),
          child: ListView.builder(
              // itemCount: _usersFromSqlLocalDataBase.length,
              itemBuilder: (context, index) {
            return Column(
              children: [
                GestureDetector(
                  onTap: (() {
                    setState(() {
                      isSelected[index] = !isSelected[index];
                      if (isSelected[index]) {
                        // selectedIDs
                        //     .add(_usersFromSqlLocalDataBase[index].id!);
                      } else {
                        // selectedIDs
                        //     .remove(_usersFromSqlLocalDataBase[index].id!);
                      }
                    });
                    print(selectedIDs.toString());
                  }),
                  child: GroupSelectContact(
                    context: context,
                    // contact: _usersFromSqlLocalDataBase[index],
                    isSelected: isSelected[index],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (selectedIDs.isNotEmpty) {
            for (int i = 0; i < selectedIDs.length; i++) {
              await addToGroupUserSql(GroupUserModel(
                      groupId: widget.id, userContactId: selectedIDs[i])
                  .toMap());
            }
            showSnackBar(context, "Group Created Successfully");
          } else {
            showSnackBar(context, "Please select atleast 1 contact");
          }
        },
        backgroundColor: const Color(0xff008069),
        child: const Icon(Icons.check),
      ),
    );
  }

//   ListTile contact_card() {
//     return const ListTile(
//       leading: Icon(Icons.circle),
//       title: Text(
//         'Dummy contact',
//         style: TextStyle(color: Colors.black),
//       ),
//       subtitle: Text('Subtitle'), //if needed
//       minLeadingWidth: 0,
//     );
//   }
}
