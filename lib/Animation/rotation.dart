import 'dart:math';
import 'package:flutter/material.dart';

class RotationAnimation {

  // Controls the animation.
  late AnimationController rotationController;

  // Defines the rotation animation.
  late Animation<double> rotationAnimation;

  // Constructor: Initializes the animation.
  RotationAnimation(TickerProvider vsync) {

    // Set up the animation controller: Runs for 1 second.
    rotationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: vsync,
      value: 0.0,
    )..repeat(); // Repeats the animation continuously.

    // Animation from 0 to 360 degrees (2π radians).
    rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(rotationController);
  }
}
