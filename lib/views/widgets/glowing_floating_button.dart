import 'package:flutter/material.dart';
import 'package:lane_dane/utils/colors.dart';

class GlowingFloatingButton extends StatefulWidget {
  final Widget child;
  const GlowingFloatingButton({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<GlowingFloatingButton> createState() => _GlowingFloatingButtonState();
}

class _GlowingFloatingButtonState extends State<GlowingFloatingButton>
    with SingleTickerProviderStateMixin {
  final double maxHeightIncrease = 30;
  final Duration duration = const Duration(seconds: 1);

  late AnimationController controller;
  late Animation<double> offsetChange;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: duration,
      vsync: this,
    )..repeat(reverse: true);

    offsetChange =
        Tween<double>(begin: maxHeightIncrease * -1, end: maxHeightIncrease * 2)
            .animate(controller);

    offsetChange.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 56 + maxHeightIncrease * 0.8,
          width: 56 + maxHeightIncrease * 0.8,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                height: 50 + offsetChange.value * 1.5,
                width: 50 + offsetChange.value * 1.5,
                duration: duration,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(100),
                  ),
                  color: greenColor.withAlpha(61),
                  border: Border.all(color: greenColor.withAlpha(61)),
                ),
              ),
              widget.child,
            ],
          ),
        ),
      ],
    );
  }
}
