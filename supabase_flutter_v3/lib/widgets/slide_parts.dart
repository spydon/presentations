import 'package:flutter_deck/flutter_deck.dart';
// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:supabase_flutter_v3/brand.dart';

/// A code listing sized for a 1080p slide.
class SlideCode extends StatelessWidget {
  const SlideCode({
    required this.code,
    this.fileName,
    this.language = 'dart',
    this.fontSize = 28,
    super.key,
  });

  final String code;
  final String? fileName;
  final String language;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return FlutterDeckCodeHighlightTheme(
      data: FlutterDeckCodeHighlightTheme.of(context).copyWith(
        backgroundColor: Brand.surface,
        textStyle: TextStyle(
          fontFamily: 'monospace',
          fontSize: fontSize,
          height: 1.4,
        ),
      ),
      child: FlutterDeckCodeHighlight(
        code: code,
        fileName: fileName,
        language: language,
      ),
    );
  }
}

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
      fontFamily: 'monospace',
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

/// A rounded box with an icon, a title and a short description.
class InfoTile extends StatelessWidget {
  const InfoTile({
    required this.icon,
    required this.title,
    required this.text,
    this.highlighted = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String text;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 56, color: Brand.green),
          const SizedBox(width: 28),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A labelled code listing, for one side of a before and after comparison.
class ComparisonCode extends StatelessWidget {
  const ComparisonCode({
    required this.label,
    required this.code,
    required this.isAfter,
    this.visible = true,
    super.key,
  });

  final String label;
  final String code;
  final bool isAfter;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final color = isAfter ? Brand.green : Brand.red;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: visible ? 1 : 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 120),
          Row(
            children: [
              Icon(
                isAfter ? Icons.check_circle : Icons.cancel,
                color: color,
                size: 40,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SlideCode(code: code, fontSize: 24),
        ],
      ),
    );
  }
}
