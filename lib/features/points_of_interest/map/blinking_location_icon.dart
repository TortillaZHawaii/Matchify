import 'package:flutter/material.dart';

class BlinkingLocationIcon extends StatefulWidget {
  final bool loading;
  const BlinkingLocationIcon({Key? key, required this.loading})
      : super(key: key);

  @override
  _BlinkingLocationIconState createState() => _BlinkingLocationIconState();
}

class _BlinkingLocationIconState extends State<BlinkingLocationIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      controller.repeat(reverse: true);
    } else {
      controller.animateTo(0);
    }

    return Stack(
      children: [
        const Icon(
          Icons.location_searching,
        ),
        FadeTransition(
          child: const Icon(
            Icons.my_location,
          ),
          opacity: controller.drive(CurveTween(curve: Curves.easeInOut)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
