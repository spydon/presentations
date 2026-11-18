// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:common/src/brand.dart';

/// A rounded box with an icon, a title and a short description.
///
/// The icon is next to the text by default, or above it with a [direction] of
/// [Axis.vertical], which suits narrow tiles side by side.
class InfoTile extends StatelessWidget {
  const InfoTile({
    required this.icon,
    required this.title,
    required this.text,
    this.highlighted = false,
    this.direction = Axis.horizontal,
    super.key,
  });

  final IconData icon;
  final String title;
  final String text;
  final bool highlighted;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: 56, color: Brand.green);
    final texts = [
      Text(
        title,
        style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(
        text,
        style: const TextStyle(
          fontSize: 26,
          color: Brand.mutedText,
          height: 1.35,
        ),
      ),
    ];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: Brand.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: highlighted ? Brand.green : Brand.surfaceHigh,
          width: highlighted ? 3 : 1,
        ),
      ),
      child: switch (direction) {
        Axis.horizontal => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            iconWidget,
            const SizedBox(width: 28),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: texts,
              ),
            ),
          ],
        ),
        Axis.vertical => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [iconWidget, const SizedBox(height: 20), ...texts],
        ),
      },
    );
  }
}
