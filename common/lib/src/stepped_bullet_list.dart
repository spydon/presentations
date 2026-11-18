import 'package:flutter_deck/flutter_deck.dart';
// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:common/src/brand.dart';

/// A bullet point with optional sub-bullets, for [SteppedBulletList].
class Bullet {
  const Bullet(this.text, {this.subBullets = const []});

  final String text;
  final List<String> subBullets;
}

/// A bullet list revealed one bullet per slide step, like
/// [FlutterDeckBulletList] with `useSteps`, but with sub-bullets.
class SteppedBulletList extends StatelessWidget {
  const SteppedBulletList({required this.bullets, super.key});

  final List<Bullet> bullets;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterDeckBulletListTheme.of(context);
    final style = theme.textStyle?.copyWith(color: theme.color);
    final subStyle = style?.copyWith(
      fontSize: (style.fontSize ?? 44) * 0.75,
      color: Brand.mutedText,
    );
    return FlutterDeckSlideStepsBuilder(
      builder: (context, step) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, bullet) in bullets.indexed)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: index < step ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BulletRow(marker: '•', text: bullet.text, style: style),
                    for (final subBullet in bullet.subBullets)
                      Padding(
                        padding: const EdgeInsets.only(left: 56, top: 6),
                        child: _BulletRow(
                          marker: '–',
                          text: subBullet,
                          style: subStyle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({required this.marker, required this.text, this.style});

  final String marker;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(marker, style: style),
        const SizedBox(width: 20),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}
