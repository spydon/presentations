// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:common/src/brand.dart';

/// A terminal window with one command per line, each revealed when [step]
/// reaches it.
class Terminal extends StatelessWidget {
  const Terminal({
    required this.commands,
    this.step,
    this.fontSize = 34,
    super.key,
  });

  final List<String> commands;

  /// The number of highlighted commands, or null to highlight all of them.
  final int? step;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: Brand.monospaceFontFamily,
      fontSize: fontSize,
      height: 1.6,
      color: Brand.text,
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 28, 40, 36),
      decoration: BoxDecoration(
        color: Brand.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Brand.surfaceHigh),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _WindowDots(),
          const SizedBox(height: 24),
          for (final (index, command) in commands.indexed)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: step == null || index == step! - 1 ? 1 : 0.35,
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: r'$ ',
                      style: TextStyle(color: Brand.green),
                    ),
                    TextSpan(text: command),
                  ],
                ),
                style: style,
              ),
            ),
        ],
      ),
    );
  }
}

class _WindowDots extends StatelessWidget {
  const _WindowDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final color in const [
          Color(0xFFFF5F57),
          Color(0xFFFEBC2E),
          Color(0xFF28C840),
        ])
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(radius: 9, backgroundColor: color),
          ),
      ],
    );
  }
}
