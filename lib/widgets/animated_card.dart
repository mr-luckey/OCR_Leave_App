import 'package:flutter/material.dart';

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final double opacity;
  final Offset offset;
  final Duration duration;

  const AnimatedCard({
    super.key,
    required this.child,
    this.opacity = 1,
    this.offset = Offset.zero,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: offset,
      duration: duration,
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: opacity,
        duration: duration,
        curve: Curves.easeInOut,
        child: Card(
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ),
    );
  }
}
