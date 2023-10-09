// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_profile_picture/flutter_profile_picture.dart';
// import 'package:lane_dane/app_controller.dart';
// import 'package:lane_dane/models/group_model.dart';
// import 'package:lane_dane/views/pages/transaction/group_transaction_screen.dart';

// class GroupListView extends StatelessWidget {
//   GroupListView({Key? key}) : super(key: key);

//   final AppController appController = Get.find();

//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;
//     final double topPadding =
//         Get.statusBarHeight + kToolbarHeight + kToolbarHeight;

//     return SizedBox(
//       height: size.height,
//       child: RefreshIndicator(
//         // onRefresh: refresh,
//         onRefresh: () async {},
//         child: SingleChildScrollView(
//           child: Obx(() {
//             List<Groups> groupsList = appController.groupsList;
//             if (groupsList.isEmpty) {
//               return Container(
//                 height: size.height - topPadding,
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 alignment: Alignment.center,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: const [
//                     PromptText(),
//                   ],
//                 ),
//               );
//             }
//             return ListView.builder(
//               shrinkWrap: true,
//               scrollDirection: Axis.vertical,
//               physics: const ScrollPhysics(),
//               itemCount: groupsList.length,
//               itemBuilder: (context, index) {
//                 Groups group = groupsList[index];
//                 void openGroupTransactionScreen() {
//                   appController.groupTransactionListGroup = group;

//                   Navigator.of(context)
//                       .pushNamed(GroupTransactionScreen.routeName, arguments: {
//                     'group': group,
//                   });
//                 }

//                 return ListTile(
//                   onTap: openGroupTransactionScreen,
//                   leading: ProfilePicture(
//                     name: group.groupName,
//                     radius: 21,
//                     fontsize: 21,
//                     random: false,
//                   ),
//                   title: Text(group.groupName),
//                   subtitle: Text(group.lastActivity.toString()),
//                 );
//               },
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }

// class PromptText extends StatelessWidget {
//   const PromptText({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }
