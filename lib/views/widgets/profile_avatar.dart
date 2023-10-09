import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  ProfileAvatar({
    Key? key,
    required this.radius,
    required this.name,
  }) : super(
          key: key,
        ) {
    _getMeInitial(name!);
  }
  ProfileAvatar.small({
    Key? key,
    required this.name,
  })  : radius = 18,
        super(
          key: key,
        ) {
    _getMeInitial(name!);
  }
  ProfileAvatar.medium({
    Key? key,
    required this.name,
  })  : radius = 26,
        super(
          key: key,
        ) {
    _getMeInitial(name!);
  }
  ProfileAvatar.large({
    Key? key,
    required this.name,
  })  : radius = 34,
        super(
          key: key,
        ) {
    _getMeInitial(name!);
  }

  final double radius;
  final String? name;
  late String initial;

  String _getMeInitial(String name) {
    final reg = RegExp(r".");
    initial = reg.firstMatch(name)?.group(0) ?? 'No Account Number Found';
    return initial;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(radius))),
      child: Text(initial),
    );
  }
}
