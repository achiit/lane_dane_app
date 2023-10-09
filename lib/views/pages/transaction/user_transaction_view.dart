import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lane_dane/app_controller.dart';
import 'package:lane_dane/controllers/user_group_entity_controller.dart';
import 'package:lane_dane/models/user_group_entity.dart';
import 'package:lane_dane/objectbox.g.dart';
import 'package:lane_dane/utils/log_printer.dart';
import 'package:lane_dane/views/widgets/single_chats.dart';

class UserTransactionScreen extends StatefulWidget {
  static const String routeName = 'user-transactions';

  UserTransactionScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<UserTransactionScreen> createState() => _UserTransactionScreenState();
}

class _UserTransactionScreenState extends State<UserTransactionScreen> {
  final log = getLogger('UserTransactionScreen');
  final AppController appController = Get.find();

  late List<UserGroupEntity> entityList;
  late StreamSubscription<Query<UserGroupEntity>> subscription;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: UserTransactionScreen.routeName,
    );
    entityList =
        appController.usergroupController.retrieveAllOrderByLastActivityTime();
    subscription = appController.usergroupController
        .streamAllOrderByLastActivityTime()
        .listen(updateUserGroupEntityList);
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<void> refresh() async {
    await appController.retrieveTransactionsFromServer();
    appController.resendFailedTransactions();
  }

  void updateUserGroupEntityList(Query<UserGroupEntity> query) {
    setState(() {
      entityList = query.find();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double topPadding =
        Get.statusBarHeight + kToolbarHeight + kToolbarHeight;

    if (entityList.isEmpty) {
      return Container(
        height: size.height - topPadding,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            PromptText(),
          ],
        ),
      );
    }
    return SizedBox(
      height: size.height,
      child: RefreshIndicator(
        onRefresh: refresh,
        child: SingleChildScrollView(
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const ScrollPhysics(),
            itemCount: entityList.length,
            itemBuilder: (context, index) {
              UserGroupEntity entity = entityList[index];
              return UserGroupListTile(entity: entity);
            },
          ),
        ),
      ),
    );
  }
}

class PromptText extends StatefulWidget {
  const PromptText({Key? key}) : super(key: key);

  @override
  State<PromptText> createState() => _PromptTextState();
}

class _PromptTextState extends State<PromptText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  );
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(1.5, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  ));

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle messageStyle = GoogleFonts.roboto(
      letterSpacing: 0.9,
      color: const Color(0xFF248A41),
      fontWeight: FontWeight.bold,
      fontSize: 22,
    );
    return SlideTransition(
      position: _offsetAnimation,
      child: Container(
        child: Column(
          children: [
            Text(
              'user_transaction_animated_text_1'.tr,
              textAlign: TextAlign.center,
              style: messageStyle,
            ),
          ],
        ),
      ),
    );
  }
}
