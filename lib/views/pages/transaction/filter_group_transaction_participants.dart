import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/utils/colors.dart';
import 'package:lane_dane/views/widgets/elevated_btn.dart';

class FilterGroupTransactionParticipants extends StatefulWidget {
  static const String routeName = 'filter-group-transaction-participants';

  final List<Users> userList;
  final int amount;
  const FilterGroupTransactionParticipants({
    Key? key,
    required this.userList,
    required this.amount,
  }) : super(key: key);

  @override
  State<FilterGroupTransactionParticipants> createState() =>
      _FilterGroupTransactionParticipantsState();
}

class _FilterGroupTransactionParticipantsState
    extends State<FilterGroupTransactionParticipants> {
  late List<Users> selectedUserList;

  @override
  void initState() {
    super.initState();
    selectedUserList = [...widget.userList];
  }

  void toggleUserSelection(Users u) {
    if (selectedUserList.contains(u)) {
      selectedUserList.remove(u);
    } else {
      selectedUserList.add(u);
    }
    setState(() {});
  }

  void submit() {
    Navigator.of(context).pop(selectedUserList);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: appBar,
      // bottomNavigationBar: addTransactionButton(),
      floatingActionButton: addTransactionFloatingButton(),
      body: SizedBox(
        height: size.height - appBar.preferredSize.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: size.height - appBar.preferredSize.height - 80,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.userList.length,
                  itemBuilder: (BuildContext context, int index) {
                    int payableAmount = 0;

                    if (selectedUserList.length > 0) {
                      payableAmount = widget.amount ~/ selectedUserList.length;
                    }

                    Users u = widget.userList[index];

                    bool userSelected() {
                      return selectedUserList.any((Users user) {
                        return user.id == u.id;
                      });
                    }

                    void checkToggled(bool? val) {
                      toggleUserSelection(u);
                    }

                    bool selected = userSelected();

                    return ListTile(
                      leading: ProfilePicture(
                        name: u.full_name!,
                        fontsize: 18,
                        random: false,
                        radius: 24,
                      ),
                      title: Text(
                        u.full_name!,
                        style: GoogleFonts.roboto(),
                      ),
                      subtitle: Text(
                        selected ? payableAmount.toString() : '0',
                        style: GoogleFonts.roboto(),
                      ),
                      trailing: Checkbox(
                        value: selected,
                        onChanged: checkToggled,
                      ),
                    );
                  }),
            ),
            // CustomButton(onPressed: submit, buttonName: 'confirm'.tr),
          ],
        ),
      ),
    );
  }

  final AppBar appBar = AppBar(
    title: Text(
      'filter_transaction_participants'.tr,
      style: GoogleFonts.roboto(),
    ),
    backgroundColor: greenColor,
  );

  addTransactionFloatingButton() {
    return FloatingActionButton(
      onPressed: submit,
      backgroundColor: mediumGreenColor,
      child: const Icon(Icons.check),
    );
  }

  Widget addTransactionButton() {
    return ElevatedButton(
      onPressed: submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: lightGreenColor,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check,
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(
            'add_group_transaction'.tr,
            style: GoogleFonts.roboto(
              // fontWeight: FontWeight.w900,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}
