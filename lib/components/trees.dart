import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Trees extends StatelessWidget {
  Trees({super.key, required this.animationSpeed, required this.isPaused});
  final Duration animationSpeed;
  final bool isPaused;
  final Tween<double> movingTrees = Tween(begin: Get.width, end: 0);
  @override
  Widget build(BuildContext context) {
    return RepeatingAnimationBuilder(
      paused: isPaused,
      animatable: movingTrees,
      duration: animationSpeed,
      builder: (context, value, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              bottom: 0,
              left: value - Get.width * 2,
              child: Image.asset("assets/images/trees.png", scale: 2),
            ),
            Positioned(
              bottom: 0,
              left: value + Get.width,
              child: Image.asset("assets/images/trees.png", scale: 2),
            ),
            Positioned(
              bottom: 0,
              left: value - Get.width,
              child: Image.asset("assets/images/trees.png", scale: 2),
            ),
            Positioned(
              bottom: 0,
              left: value,
              child: Image.asset("assets/images/trees.png", scale: 2),
            ),
          ],
        );
      },
    );
  }
}
