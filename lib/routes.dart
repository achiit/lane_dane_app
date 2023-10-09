import 'package:flutter/material.dart';
import 'package:lane_dane/models/all_transaction.dart';
import 'package:lane_dane/models/group_model.dart';
import 'package:lane_dane/models/transactions.dart';
import 'package:lane_dane/models/users.dart';
import 'package:lane_dane/views/introscreens/intro_main.dart';
import 'package:lane_dane/views/pages/add_new_contact.dart';
import 'package:lane_dane/views/pages/home/create_group.dart';
import 'package:lane_dane/views/pages/language_setting.dart';
import 'package:lane_dane/views/pages/premium_details.dart';
import 'package:lane_dane/views/pages/authentication/enter_otp_screen.dart';
import 'package:lane_dane/views/pages/authentication/enter_phone_screen.dart';
import 'package:lane_dane/views/pages/authentication/user_meta_info_page.dart';
import 'package:lane_dane/views/pages/home/about_us_page.dart';
import 'package:lane_dane/views/pages/home/feedback_page.dart';
import 'package:lane_dane/views/pages/home/help_page.dart';
import 'package:lane_dane/views/pages/home/home.dart';
import 'package:lane_dane/views/pages/home/share_page.dart';
import 'package:lane_dane/views/pages/profile/user_profile.dart';
import 'package:lane_dane/views/pages/transaction/add_group_transaction.dart';
import 'package:lane_dane/views/pages/transaction/add_transaction.dart';
import 'package:lane_dane/views/pages/transaction/all_transaction_view.dart';
import 'package:lane_dane/views/pages/transaction/filter_group_transaction_participants.dart';
import 'package:lane_dane/views/pages/transaction/personal_transaction_view.dart';
import 'package:lane_dane/views/pages/transaction/transaction_details.dart';
import 'package:lane_dane/views/pages/transaction/user_transaction_view.dart';
import 'package:lane_dane/views/pages/transaction_reminder_setting.dart';
import 'package:lane_dane/views/pages/update_page.dart';

import 'views/pages/selectContact.dart';
import 'views/pages/transaction/group_transaction_screen.dart';

/// Right now I have created my own MaterialPageRoute with the animations.
/// But a MaterialPageRoute class already exists in the Flutter framework.
/// This implementation is not a subclass or an extension/override.
/// It is simply a name conflict, which will prevent the inbuilt class from being shown.
/// If there is a need to rename it to a custom class, change all invocations of MaterialPageRoute in this file to preserve the animations
class MaterialPageRoute extends PageRouteBuilder {
  final Widget Function(BuildContext) builder;
  MaterialPageRoute({
    required this.builder,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return builder(context);
          },
          settings: settings,
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case LanguageSetting.routeName:
      Map<String, dynamic>? args =
          routeSettings.arguments as Map<String, dynamic>?;
      final void Function() postSettingCallback =
          args?['post_setting_callback'] ??
              () {
                print(
                    'No postSettingCallback assigned in routes.dart, case LanguageSetting.routeName');
              };
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => LanguageSetting(
          postSettingCallback: postSettingCallback,
        ),
      );
    case UpdatePage.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const UpdatePage(),
      );
    case Home.routeName:
      // var contact = routeSettings.arguments as List<Contact>;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Home(),
      );
    case HelpPage.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const HelpPage(),
      );
    case FeedbackPage.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const FeedbackPage(),
      );
    case SharePage.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const SharePage(),
      );
    case AboutUsPage.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AboutUsPage(),
      );
      case IntroMain.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const IntroMain(),
      );
    case SelectContact.routeName:
      // var smsData = routeSettings.arguments as Map<String, dynamic>?;
      Map<String, dynamic>? args =
          routeSettings.arguments as Map<String, dynamic>?;
      final bool multiSelect = args?['multi_select'] ?? false;
      final bool listGroups = args?['list_groups'] ?? false;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => SelectContact(
          multiSelect: multiSelect,
          listGroups: listGroups,
          // smsData: smsData,
        ),
      );
    case AddNewContact.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AddNewContact(),
      );
    case AddTransaction.routeName:
      var arguments = routeSettings.arguments as Map<String, dynamic>;
      if (!arguments.containsKey('contact')) {
        throw 'Missing data contact';
      }
      final Users contact = arguments['contact'];
      final int? allTransactionId = arguments['all_transaction_id'];
      final int? transactionId = arguments['transaction_id'];
      final int? amount = arguments['amount'];
      final TransactionType? transactionType = arguments['transaction_type'];
      final PaymentStatus? paymentStatus = arguments['payment_status'];
      final int? categoryId = arguments['category_id'];
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => AddTransaction(
          contact: contact,
          allTransactionId: allTransactionId,
          transactionId: transactionId,
          amount: amount,
          transactionType: transactionType,
          paymentStatus: paymentStatus,
          categoryId: categoryId,
        ),
      );
    case AddGroupTransaction.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) {
          dynamic arguments = routeSettings.arguments as Map<String, dynamic>;
          Groups group = arguments['group'];
          int? amount = arguments['amount'];
          int? allTransactionId = arguments['all_transaction_id'];
          return AddGroupTransaction(
            group: group,
            amount: amount,
            allTransactionId: allTransactionId,
          );
        },
      );
    case FilterGroupTransactionParticipants.routeName:
      dynamic arguments = routeSettings.arguments;
      List<Users> userList = arguments['user_list'];
      int amount = arguments['amount'];
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => FilterGroupTransactionParticipants(
          userList: userList,
          amount: amount,
        ),
      );
    case GroupTransactionScreen.routeName:
      dynamic arguments = routeSettings.arguments;
      Groups group = arguments['group'];
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => GroupTransactionScreen(
          group: group,
        ),
      );
    case PersonalTransactions.routeName:
      var transaction = routeSettings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => PersonalTransactions(
          objects: transaction,
          contact: transaction['contact'],
        ),
      );
    case PremiumDetails.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const PremiumDetails(),
      );
    case TransactionReminderSetting.routeName:
      Map<String, dynamic> arguments =
          routeSettings.arguments as Map<String, dynamic>;
      List<TransactionsModel> completeTransactionList =
          arguments['transactions'];
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => TransactionReminderSetting(
          completeTransactionList: completeTransactionList,
        ),
      );
    case TransactionDetails.routeName:
      final Map<String, dynamic> arguments =
          routeSettings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(builder: (_) {
        return TransactionDetails(
          transaction: arguments['transaction'] as TransactionsModel?,
          contact: arguments['contact'] as Users?,
          allTransaction:
              arguments['alltransaction'] as AllTransactionObjectBox?,
        );
      });
    case UserProfile.routeName:
      Map<String, dynamic> arguments =
          routeSettings.arguments as Map<String, dynamic>;
      Users user = arguments['contact'];
      List<TransactionsModel> transactionHistory = arguments['transaction'];
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => UserProfile(
          user: user,
          transactionHistory: transactionHistory,
        ),
      );
    case UserTransactionScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => UserTransactionScreen(),
      );
    case CreateGroupScreen.routeName:
      dynamic arguments = routeSettings.arguments as Map<String, dynamic>;
      List<Users> userList = arguments['user_list'] ?? [];
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => CreateGroupScreen(
          userList: userList,
        ),
      );
    case EnterOtpScreen.routeName:
      var args = routeSettings.arguments as Map<String, dynamic>;
      var phone = args['phoneNumber'];
      var res = args['httpResponse'];
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => EnterOtpScreen(phoneNumber: phone, httpResponse: res),
      );
    case UserMetaInfoPage.routeName:
      var args = routeSettings.arguments as Map<String, dynamic>;
      var phone = args['phone'];
      var otp = args['otp'];
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => UserMetaInfoPage(otp: otp, phone: phone),
      );
    case EnterPhoneScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const EnterPhoneScreen(),
      );
    case AllTransaction.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AllTransaction(),
      );
    default:
      // Return your own error 404 screen.
      // TODO: Design your own error 404 screen
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Error 404'),
          ),
        ),
      );
  }
}
