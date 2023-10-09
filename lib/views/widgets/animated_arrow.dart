import 'package:flutter/material.dart';
import 'package:lane_dane/utils/colors.dart';

class AnimatedArrow extends StatefulWidget {
  final Color arrowColor;
  final double size;
  const AnimatedArrow({
    Key? key,
    required this.arrowColor,
    this.size = 54,
  }) : super(key: key);

  @override
  State<AnimatedArrow> createState() => _AnimatedArrowState();
}

class _AnimatedArrowState extends State<AnimatedArrow>
    with SingleTickerProviderStateMixin {
  final double maxHeightIncrease = 30;
  final Duration duration = const Duration(seconds: 1);

  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: duration,
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: 56,
      duration: duration,
      alignment: Alignment.centerLeft,
      child: SlideTransition(
        position: Tween<Offset>(
                begin: const Offset(-0.2, 0), end: const Offset(0.1, 0))
            .animate(controller),
        child: Icon(
          Icons.arrow_right_alt_outlined,
          size: widget.size,
          color: widget.arrowColor,
        ),
      ),
    );
  }
}
