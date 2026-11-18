// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

/// Fades and springs [child] in the first time it is built.
class PopIn extends StatelessWidget {
  const PopIn({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.elasticOut,
      builder: (context, value, child) => Opacity(
        opacity: value.clamp(0, 1),
        child: Transform.scale(scale: 0.6 + 0.4 * value, child: child),
      ),
      child: child,
    );
  }
}
