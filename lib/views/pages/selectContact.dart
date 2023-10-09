/*
This file is the page of the app where all contacts are displayed(registered & un-registered)

-> It fethces the contacts from the local Sql Database on users device and displays them in the listTile View using listView.builder

-> //!!! 1 API CALL IS DONE () -> fetchNativeContacts() 
during init state()

 */
import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/controllers/contact_controller.dart';
import 'package:lane_dane/controllers/group_controller.dart';
import 'package:lane_dane/controllers/users_controller.dart';
import 'package:lane_dane/models/group_model.dart';
import 'package:lane_dane/models/transaction_entity.dart';
import 'package:lane_dane/models/user_group_entity.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/objectbox.g.dart';
import 'package:lane_dane/utils/colors.dart';
import 'package:lane_dane/utils/string_extensions.dart';
import 'package:lane_dane/views/pages/add_new_contact.dart';
import 'package:lane_dane/views/pages/contact_permission_view.dart';
import 'package:lane_dane/views/pages/sms_permission_view.dart';
import 'package:lane_dane/views/widgets/single_group_widget.dart';
import 'package:logger/logger.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:lane_dane/main.dart';
import 'package:lane_dane/views/widgets/SingleContacts.dart';

class SelectContact extends StatefulWidget {
  /// Screen that displays native contact and allows selecting either one or
  /// several contacts and returns them (The returned value is either a single
  /// ```Users```, ```Groups``` or list of ```Users```).
  ///
  /// Pass a map:
  /// ```dart
  /// {
  ///   'multi_select': bool
  ///   'list_groups': bool
  /// }
  /// ```
  /// in order to choose between selecting a single contact or a list of
  /// contacts when navigating using named routes. If [multiSelect] is set to
  /// true, the return value is of the type ```List<Users>``` and if
  /// ```multiSelect``` is false, the return value is of the type ```Users```.
  /// Similarly if ```list_groups``` is set to true, the screen will list local
  /// groups as well as contacts. If set to false, only individual contacts will
  /// be displayed.
  static const String routeName = 'select-contact-screen';
  final bool multiSelect;
  final bool listGroups;

  const SelectContact({
    Key? key,
    this.multiSelect = false,
    this.listGroups = false,
  }) : super(key: key);

  @override
  State<SelectContact> createState() => _SelectContactState();
}

class _SelectContactState extends State<SelectContact> {
  late final Logger log;
  late final AppController appController;
  late List<Users> queriedUserList;
  late List<Groups> queriedGroupList;
  late List<Users> userList;
  late List<Groups> groupList;
  late StreamSubscription userListStream;
  late StreamSubscription groupListStream;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: SelectContact.routeName,
    );
    log = getLogger('SelectContact');
    appController = Get.find();

    userList = appController.userController.retrieveAll();
    userListStream = appController.userController
        .streamAllOrderByName()
        .listen(updateUserList);

    groupList = appController.groupController.retrieveAll();
    userListStream = appController.groupController
        .streamAllOrderByName()
        .listen(updateGroupList);

    resetQueryList();
    if (appController.permissions.contactReadPermission) {
      resetQueryList();
    }
    userListFetchProcess();
  }

  bool canShowGroupList() {
    return widget.listGroups && !widget.multiSelect;
  }

  void resetQueryList() {
    queriedUserList = userList;
    if (canShowGroupList()) {
      queriedGroupList = groupList;
    } else {
      queriedGroupList = [];
    }
  }

  void updateUserList(Query<Users> query) {
    if (mounted) {
      setState(() {
        userList = query.find();
        resetQueryList();
      });
    }
  }

  void updateGroupList(Query<Groups> query) {
    if (mounted) {
      setState(() {
        groupList = query.find();
        resetQueryList();
      });
    }
  }

  Future<void> userListFetchProcess() async {
    if (!appController.permissions.contactReadPermission) {
      await appController.permissions.requestContactsReadPermission();
      if (mounted) {
        setState(() {});
      }
    }
    try {
      await appController.loadNewContacts();
      // IsolateSpawn().getContact();
      if (appController.permissions.contactReadPermission) {
        resetQueryList();
      }
    } catch (err) {
      log.e(err);
    }
  }

  void queryResults(String query) {
    if (query.isEmpty) {
      resetQueryList();
      setState(() {});
      return;
    }
    if (query.isNumericOnly) {
      query = query.phoneNumber.replaceAll('+', '');
    }

    queriedUserList = userList.where((Users u) {
      int indexFound = -1;
      indexFound =
          u.name().toLowerCase().split(' ').indexWhere((String nameSubString) {
        return nameSubString.startsWith(query.toLowerCase());
      });

      if (indexFound == -1 &&
          (u.type() == UserGroupEntityType.user) &&
          (query.length >= 2)) {
        indexFound = u.phoneNumber.contains(query) ? 0 : -1;
      }
      return indexFound >= 0;
    }).toList();

    if (queriedUserList.isEmpty) {
      queriedUserList = userList.where((Users u) {
        return u.name().isCaseInsensitiveContains(query);
      }).toList();
    }

    if (canShowGroupList()) {
      queriedGroupList = groupList.where((Groups g) {
        int indexFound = -1;
        indexFound = g
            .name()
            .toLowerCase()
            .split(' ')
            .indexWhere((String nameSubString) {
          return nameSubString.startsWith(query.toLowerCase());
        });
        return indexFound >= 0;
      }).toList();

      if (queriedGroupList.isEmpty) {
        queriedGroupList = groupList.where((Groups g) {
          return g.name().isCaseInsensitiveContains(query);
        }).toList();
      }
    }
    setState(() {});
  }

  Future<void> refreshContactList() async {
    ContactController.contactsStored = false;
    userListFetchProcess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: BuildAppBar(onTextChangeCallback: queryResults),
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: refreshContactList,
        child: Builder(
          builder: (BuildContext context) {
            // AppController appController = Get.find();
            bool permissionGranted =
                appController.permissions.contactReadPermission;

            if ((permissionGranted && ContactController.contactsStored) ||
                (permissionGranted && userList.isNotEmpty)) {
              return ContactList(
                users: queriedUserList,
                groups: queriedGroupList,
                multiSelect: widget.multiSelect,
                // smsData: widget.smsData,
              );
            } else if (appController.permissions.contactReadPermission) {
              return const ContactLoadingView();
            } else {
              return ContactPermissionView(
                onPressed: userListFetchProcess,
              );
            }
          },
        ),
      ),
    );
  }
}

class ContactList extends StatefulWidget {
  final List<Users> users;
  final List<Groups> groups;
  final bool multiSelect;

  const ContactList({
    Key? key,
    required this.users,
    required this.groups,
    required this.multiSelect,
  }) : super(key: key);

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  final log = getLogger('SelectContact');
  final AppController appController = Get.find();

  late List<Users> multiSelectUserList;
  late Stream multiSelectUserStream;
  late GlobalKey<AnimatedListState> animatedListKey;
  late ScrollController selectedContactListScrollController;
  late double selectedContactListHeight;
  late Duration selectedContactInflateDuration;

  @override
  void initState() {
    super.initState();
    multiSelectUserList = [];
    animatedListKey = GlobalKey<AnimatedListState>();
    selectedContactListScrollController =
        ScrollController(keepScrollOffset: true);
    selectedContactListHeight = 0;
    selectedContactInflateDuration = const Duration(milliseconds: 300);
  }

  void contactTapCallback(TransactionEntity entity) {
    if (!widget.multiSelect) {
      appController.userController
          .updateUserIncrementTapCount(entity.entityId());
      Navigator.of(context).pop<TransactionEntity?>(entity);
      return;
    }
    if (entity.type() == UserGroupEntityType.group) {
      return;
    }
    Users user = entity as Users;
    if (multiSelectUserList.contains(user)) {
      int removeIndex =
          multiSelectUserList.indexWhere((Users u) => user.id == u.id);
      multiSelectUserList.removeAt(removeIndex);
      animatedListKey.currentState!.removeItem(
        removeIndex,
        (BuildContext context, Animation<double> animation) {
          return ScaleTransition(
            scale: animation,
            child: SelectedContact(user: user),
          );
        },
        duration: selectedContactInflateDuration,
      );
      if (multiSelectUserList.isEmpty) {
        selectedContactListHeight = 0;
      }
    } else {
      selectedContactListHeight = 80;

      multiSelectUserList.insert(0, user);
      animatedListKey.currentState!.insertItem(
        0,
        duration: selectedContactInflateDuration,
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  void completeMultiSelect() {
    // add group functionality here
    Navigator.of(context).pop(multiSelectUserList);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    // ANALYTICS.setCurrentScreen(screenName: 'SelectContact');
    return Scaffold(
      floatingActionButton: widget.multiSelect
          ? FloatingActionButton(
              backgroundColor: lightGreenColor,
              onPressed: completeMultiSelect,
              child: const Icon(
                Icons.arrow_forward,
              ),
            )
          : Container(),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return selectedContactList();
              },
              childCount: 1,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return addContactOption();
              },
              childCount: 1,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return createGroupOption();
              },
              childCount: 1,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return groupsLabel();
              },
              childCount: 1,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                Groups entity = widget.groups[index];
                return GestureDetector(
                  onTap: () => contactTapCallback(entity),
                  child: SingleGroupWidget(
                    group: entity,
                  ),
                );
              },
              childCount: widget.groups.length,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return usersLabel();
              },
              childCount: 1,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                Users entity = widget.users[index];
                return GestureDetector(
                  onTap: () => contactTapCallback(entity),
                  child: SingleContacts(
                    contact: entity,
                    selected:
                        multiSelectUserList.contains(entity) ? true : false,
                  ),
                );
              },
              childCount: widget.users.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget addContactOption() {
    if (widget.multiSelect) {
      return Container();
    } else {
      return const AddContactOption();
    }
  }

  Widget createGroupOption() {
    if (widget.multiSelect) {
      return Container();
    } else {
      return const CreateGroupOption();
    }
  }

  Widget groupsLabel() {
    if (widget.groups.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        color: Colors.white,
        child: Text('groups'.tr, style: GoogleFonts.roboto()),
      );
    } else {
      return Container();
    }
  }

  Widget usersLabel() {
    if (widget.users.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        color: Colors.white,
        child: Text('users'.tr, style: GoogleFonts.roboto()),
      );
    } else {
      return Container();
    }
  }

  Widget selectedContactList() {
    final Size size = MediaQuery.of(context).size;

    return AnimatedContainer(
      width: size.width,
      height: selectedContactListHeight,
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      alignment: Alignment.centerLeft,
      color: Colors.white,
      duration: const Duration(milliseconds: 250),
      child: OverflowBox(
        alignment: Alignment.topLeft,
        minHeight: 0,
        maxHeight: 100,
        child: AnimatedList(
          key: animatedListKey,
          scrollDirection: Axis.horizontal,
          reverse: true,
          shrinkWrap: true,
          controller: selectedContactListScrollController,
          itemBuilder:
              (BuildContext context, int index, Animation<double> animation) {
            Users user = multiSelectUserList[index];
            return ScaleTransition(
              scale: animation,
              child: GestureDetector(
                onTap: () => contactTapCallback(user),
                child: SelectedContact(user: user),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AddContactOption extends StatelessWidget {
  const AddContactOption({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> addContact() async {
      AppController appController = Get.find();
      dynamic user =
          await Navigator.of(context).pushNamed(AddNewContact.routeName);
      if (user == null) return;

      if (context.mounted) {
        Navigator.of(context).pop(user);
      }
    }

    return ListTile(
      onTap: addContact,
      tileColor: Colors.white,
      leading: CircleAvatar(
        backgroundColor: greenColor,
        child: const Icon(
          Icons.person_add,
          color: Colors.white,
        ),
      ),
      title: Text(
        'new_contact'.tr,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class CreateGroupOption extends StatelessWidget {
  const CreateGroupOption({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> addContact() async {
      dynamic group = await Navigator.of(context)
          .pushNamed(SelectContact.routeName, arguments: {
        'multi_select': true,
      });
      if (group == null) return;
      if (context.mounted) {
        Navigator.of(context).pop(group);
      }
    }

    return ListTile(
      onTap: addContact,
      tileColor: Colors.white,
      leading: CircleAvatar(
        backgroundColor: greenColor,
        child: const Icon(
          Icons.group_add,
          color: Colors.white,
        ),
      ),
      title: Text(
        'new_group'.tr,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class SelectedContact extends StatelessWidget {
  final Users user;
  const SelectedContact({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              ProfilePicture(
                name: user.name(),
                radius: 20,
                fontsize: 18,
              ),
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.bottomRight,
                child: const Icon(
                  Icons.remove_circle,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            user.name(),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(),
          ),
        ],
      ),
    );
  }
}

class BuildAppBar extends StatefulWidget {
  final void Function(String) onTextChangeCallback;
  const BuildAppBar({
    Key? key,
    required this.onTextChangeCallback,
  }) : super(key: key);

  @override
  State<BuildAppBar> createState() => _BuildAppBarState();
}

class _BuildAppBarState extends State<BuildAppBar> {
  late bool textInputMode;
  late final TextEditingController queryController;

  @override
  void initState() {
    super.initState();
    textInputMode = false;
    queryController = TextEditingController();
  }

  @override
  void dispose() {
    queryController.dispose();
    super.dispose();
  }

  void toggleTextInputMode() {
    if (textInputMode) {
      queryController.clear();
    }
    if (mounted) {
      setState(() {
        textInputMode = !textInputMode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        padding: const EdgeInsets.only(left: 5),
        icon: Icon(
          Icons.arrow_back,
          color: textInputMode ? Colors.grey : Colors.white,
        ),
        onPressed: () {
          if (textInputMode) {
            widget.onTextChangeCallback('');
            toggleTextInputMode();
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
      title: !textInputMode
          ? Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                'select_contact'.tr,
                style: GoogleFonts.roboto(),
              ),
            )
          : querySearchWidget(
              controller: queryController,
              onChangedCallback: widget.onTextChangeCallback,
            ),
      // centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            color: textInputMode ? Colors.grey : Colors.white,
          ),
          onPressed: !textInputMode
              ? toggleTextInputMode
              : () {
                  widget.onTextChangeCallback(queryController.text);
                  toggleTextInputMode();
                },
        ),
      ],
      backgroundColor: textInputMode ? Colors.white : const Color(0xFF128C7E),
    );
  }

  Widget querySearchWidget({
    required TextEditingController controller,
    required void Function(String) onChangedCallback,
  }) {
    const OutlineInputBorder borderStyle = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    );

    final TextStyle searchInputStyle = GoogleFonts.roboto(
      fontWeight: FontWeight.w600,
      fontSize: 20,
    );

    return TextFormField(
      controller: controller,
      onChanged: onChangedCallback,
      autofocus: true,
      cursorColor: Colors.lightBlue,
      textAlignVertical: TextAlignVertical.center,
      style: searchInputStyle,
      decoration: InputDecoration(
        hintText: 'search_contact'.tr,
        hintStyle: searchInputStyle,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        border: borderStyle,
        focusedBorder: borderStyle,
        enabledBorder: borderStyle,
        constraints: BoxConstraints(
          maxHeight: Scaffold.of(context).appBarMaxHeight! - 40,
        ),
      ),
    );
  }
}
