import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Widget for pulsating animation effect.
class PulseAnimation extends StatefulWidget {
  final Widget child;  // Child widget to animate.

  PulseAnimation({required this.child});

  @override
  _PulseAnimationState createState() => _PulseAnimationState(); // State creation.
}

// State class for PulseAnimation.
class _PulseAnimationState extends State<PulseAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller; // Controls the animation.
  late Animation<double> _animation;     // Defines the animation.

  @override
  void initState() {
    super.initState();
    // Initialize and configure animation controller.
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Set up tween animation.
    _animation = Tween<double>(begin: 0, end: 25).animate(_controller)
      ..addListener(() {
        setState(() {}); // Rebuilds on animation tick.
      });

    _controller.repeat(reverse: false); // Continuous animation.
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up controller.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build widget with pulsating effect.
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        // Animated circle.
        Transform.translate(
          offset: Offset(0, 0),
          child: Container(
            width: _animation.value,
            height: _animation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(1 - _animation.value / 50),
            ),
          ),
        ),
        widget.child, // Positioned child widget.
      ],
    );
  }
}
