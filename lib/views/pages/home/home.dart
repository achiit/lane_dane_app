import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/models/group_model.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/utils/colors.dart';
import 'package:lane_dane/utils/constants.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:lane_dane/views/pages/authentication/enter_phone_screen.dart';
import 'package:lane_dane/views/pages/home/about_us_page.dart';
import 'package:lane_dane/views/pages/home/create_group.dart';
import 'package:lane_dane/views/pages/home/feedback_page.dart';
import 'package:lane_dane/views/pages/home/help_page.dart';
import 'package:lane_dane/views/pages/home/homeSearchDelegate.dart';
import 'package:lane_dane/views/pages/language_setting.dart';
import 'package:lane_dane/views/pages/profile/profile_view.dart';
import 'package:lane_dane/views/pages/selectContact.dart';
import 'package:lane_dane/views/pages/transaction/add_group_transaction.dart';
import 'package:lane_dane/views/pages/transaction/add_transaction.dart';
import 'package:lane_dane/views/pages/transaction/all_transaction_view.dart';
import 'package:lane_dane/views/pages/transaction/personal_transaction_view.dart';
import 'package:lane_dane/views/pages/transaction/user_transaction_view.dart';
import 'package:lane_dane/views/pages/update_page.dart';
import 'package:lane_dane/views/widgets/animated_arrow.dart';

import '../../widgets/glowing_floating_button.dart';

enum PopupMenuItemOptions {
  newtransaction,
  help,
  feedback,
  rateus,
  sharewithfriend,
  aboutus,
  changelanguage,
  update,
  logout,
}

class Home extends StatefulWidget {
  static const String routeName = 'home';

  const Home({
    Key? key,
  }) : super(key: key);

  // final List<Contact> fetchedContacts;

  @override
  _HomeState createState() => _HomeState();
}

class TabKeys {
  static final tab1Key = GlobalKey<RefreshIndicatorState>();
  static final tab2Key = GlobalKey<RefreshIndicatorState>();
  static final tab3Key = GlobalKey<RefreshIndicatorState>();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final AppController appController = Get.find();
  final log = getLogger('Home');

  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> shareApp() async {
    await Share.share(
      'Hey, check out this app I use for tracking all my financial dealings. ${Constants.appLink}',
      subject: 'Lane Dane Invitation',
    );
  }

  bool updateAvailable() {
    try {
      return appController.packageInfo != appController.newPackage;
    } catch (err) {
      return true;
    }
  }

  Future<void> popupMenuOnSelect(PopupMenuItemOptions value) async {
    switch (value) {
      case PopupMenuItemOptions.newtransaction:
        dynamic user = await Navigator.of(context).pushNamed(
          SelectContact.routeName,
          arguments: {'multi_select': false},
        );
        if (user != null) {
          var transaction = await Navigator.of(context).pushNamed(
            AddTransaction.routeName,
            arguments: {
              'contact': user,
            },
          );
          if (transaction != null) {
            Navigator.of(context).pushNamed(
              PersonalTransactions.routeName,
              arguments: {
                'contact': user,
              },
            );
          }
        }
        break;
      case PopupMenuItemOptions.help:
        Navigator.of(context).pushNamed(HelpPage.routeName);
        break;
      case PopupMenuItemOptions.feedback:
        Navigator.of(context).pushNamed(FeedbackPage.routeName);
        break;
      case PopupMenuItemOptions.rateus:
        launchUrl(Uri.parse(Constants.appLink),
            mode: LaunchMode.externalApplication);
        break;
      case PopupMenuItemOptions.sharewithfriend:
        shareApp();
        break;
      case PopupMenuItemOptions.aboutus:
        Navigator.of(context).pushNamed(AboutUsPage.routeName);
        break;
      case PopupMenuItemOptions.changelanguage:
        Navigator.of(context).pushNamed(LanguageSetting.routeName, arguments: {
          'post_setting_callback': () {
            Navigator.of(context).pop();
          }
        });
        break;
      case PopupMenuItemOptions.update:
        Navigator.of(context).pushNamed(UpdatePage.routeName);
        break;
      case PopupMenuItemOptions.logout:
        appController.logout();
        Navigator.of(context).pushNamedAndRemoveUntil(
            EnterPhoneScreen.routeName, (route) => false);
        const SnackBar(content: Text('You\'ve been logged out'));
        break;
    }
  }

  void search() {
    log.d('Search Button Pressed');
    showSearch(
      context: context,
      delegate: HomeSearchDelegate(),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle defaultStyle = GoogleFonts.roboto();

    return Scaffold(
      floatingActionButton: HomeFloatingActionButton(
        controller: _controller,
      ),
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          'lane_dane'.tr,
          style: defaultStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF128C7E),
        actions: [
          IconButton(
            onPressed: search,
            icon: const Icon(Icons.search),
          ),
          PopupMenuButton<PopupMenuItemOptions>(
            onSelected: popupMenuOnSelect,
            itemBuilder: (BuildContext context) {
              return popupMenuItems();
            },
          ),
          // IconButton(
          //   onPressed: () {
          //     log.d('Scan UPI Button Pressed');
          //     // Get.to(() => const UpiEnterScanPage());
          //     Navigator.of(context).pushNamed(UpiEnterScanPage.routeName);
          //   },
          //   icon: const Icon(Icons.qr_code_scanner),
          // ),
        ],
        bottom: TabBar(
          controller: _controller,
          indicatorColor: const Color.fromARGB(255, 37, 192, 206),
          labelColor: const Color.fromARGB(255, 255, 255, 255),
          unselectedLabelColor: Colors.black54,
          tabs: const [
            Tab(child: Icon(Icons.account_balance_wallet_rounded)),
            Tab(child: Icon(Icons.group)),
            Tab(child: Icon(Icons.account_circle_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: tabViews(),
      ),
    );
  }

  List<Tab> tabViews() {
    return [
      const Tab(
        child: AllTransaction(),
      ),
      Tab(
        child: UserTransactionScreen(),
      ),
      const Tab(
        child: Profile(),
      ),
    ];
  }

  List<PopupMenuItem<PopupMenuItemOptions>> popupMenuItems() {
    TextStyle defaultStyle = GoogleFonts.roboto();

    List<PopupMenuItem<PopupMenuItemOptions>> options = [
      PopupMenuItem(
        value: PopupMenuItemOptions.newtransaction,
        child: Text(
          'new_transaction'.tr,
          style: defaultStyle,
        ),
      ),
      PopupMenuItem(
        value: PopupMenuItemOptions.help,
        child: Text(
          'help'.tr,
          style: defaultStyle,
        ),
      ),
      PopupMenuItem(
        value: PopupMenuItemOptions.feedback,
        child: Text(
          'feedback'.tr,
          style: defaultStyle,
        ),
      ),
      PopupMenuItem(
        value: PopupMenuItemOptions.rateus,
        child: Text(
          'rate_us'.tr,
          style: defaultStyle,
        ),
      ),
      PopupMenuItem(
        value: PopupMenuItemOptions.sharewithfriend,
        child: Text(
          'share_with_friend'.tr,
          style: defaultStyle,
        ),
      ),
      PopupMenuItem(
        value: PopupMenuItemOptions.aboutus,
        child: Text(
          'about_us'.tr,
          style: defaultStyle,
        ),
      ),
      PopupMenuItem(
        value: PopupMenuItemOptions.changelanguage,
        child: Text(
          'change_language'.tr,
          style: defaultStyle,
        ),
      ),
      PopupMenuItem(
        value: PopupMenuItemOptions.logout,
        child: Text(
          'log_out'.tr,
          style: defaultStyle,
        ),
      ),
    ];
    if (updateAvailable()) {
      options.insert(
        options.length - 1,
        PopupMenuItem(
          value: PopupMenuItemOptions.update,
          child: Text(
            'update_the_app'.tr,
            style: defaultStyle,
          ),
        ),
      );
    }
    return options;
  }
}

class HomeFloatingActionButton extends StatefulWidget {
  final TabController controller;

  const HomeFloatingActionButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<HomeFloatingActionButton> createState() =>
      _HomeFloatingActionButtonState();
}

class _HomeFloatingActionButtonState extends State<HomeFloatingActionButton> {
  final AppController appController = Get.find();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(rebuild);
    super.dispose();
  }

  void rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> addTransaction() async {
    // ANALYTICS.logEvent(
    //   name: 'Select_Contact_button',
    //   parameters: {
    //     'action': 'User Pressed the + button',
    //   },
    // );

    dynamic selectContactResponse =
        await Navigator.of(context).pushNamed(SelectContact.routeName);
    if (selectContactResponse == null) {
      return;
    }
    if (selectContactResponse.runtimeType == Users) {
      createPersonalTransaction(selectContactResponse);
    }
    if (selectContactResponse.runtimeType == List<Users>) {
      createGroupTransaction(selectContactResponse);
    }
    if (selectContactResponse.runtimeType == Groups) {
      navigateToAddGroupTransaction(selectContactResponse);
    }
  }

  void navigateToAddPersonalTransaction(Users user) {
    Navigator.of(context).pushNamed(PersonalTransactions.routeName, arguments: {
      'contact': user,
    });
  }

  void navigateToAddGroupTransaction(Groups group) {
    Navigator.of(context).pushNamed(AddGroupTransaction.routeName, arguments: {
      'group': group,
    });
  }

  Future<void> createPersonalTransaction(Users user) async {
    var transaction = await Navigator.of(context).pushNamed(
      AddTransaction.routeName,
      arguments: {'contact': user},
    );
    if (transaction == null) {
      return;
    }
    navigateToAddPersonalTransaction(user);
  }

  Future<void> createGroupTransaction(List<Users> userList) async {
    dynamic group = await Navigator.of(context)
        .pushNamed(CreateGroupScreen.routeName, arguments: {
      'user_list': userList,
    });
    if (group == null || !mounted) {
      return;
    }
    navigateToAddGroupTransaction(group);
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.controller.index) {
      case 0:
        return empty();
      case 1:
        return transactionFloatingActionButton();
      case 2:
        return empty();
      default:
        return Container();
    }
  }

  Widget empty() {
    return Container();
  }

  Widget transactionFloatingActionButton() {
    if (true) {
      // TODO: Add logic to check if animated button is required or not
      return FloatingActionButton(
        backgroundColor: const Color(0xFF128C7E),
        onPressed: addTransaction,
        child: const Icon(Icons.add),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedArrow(
          arrowColor: greenColor,
        ),
        GlowingFloatingButton(
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF128C7E),
            onPressed: addTransaction,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
