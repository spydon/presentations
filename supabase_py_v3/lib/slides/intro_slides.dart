import 'package:common/common.dart';
import 'package:flutter_deck/flutter_deck.dart';
// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

class TitleSlide extends FlutterDeckSlideWidget {
  const TitleSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/intro',
          title: "What's new in supabase-py v3",
          footer: FlutterDeckFooterConfiguration(showFooter: false),
          speakerNotes:
              '- Two minutes on the supabase-py v3 alpha.\n'
              '- The big theme: types, generated from your database and checked before the code runs.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SupabaseLogo(height: 96),
            SizedBox(height: 64),
            Text(
              'supabase-py v3',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 120,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Typed from the database to your code.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 52, color: Brand.mutedText),
            ),
            SizedBox(height: 72),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Pill(icon: Icons.schema_outlined, text: 'Generated types'),
                SizedBox(width: 32),
                _Pill(
                  icon: Icons.verified_outlined,
                  text: 'Type checked queries',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: Brand.green, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Brand.green, size: 40),
          const SizedBox(width: 16),
          Text(text, style: const TextStyle(fontSize: 36, color: Brand.green)),
        ],
      ),
    );
  }
}

class OutroSlide extends FlutterDeckSlideWidget {
  const OutroSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/try-it',
          title: 'Try it today',
          header: FlutterDeckHeaderConfiguration(title: 'Try it today'),
          speakerNotes:
              '- v3 is an alpha on PyPI, so pip needs --pre to pick it.\n'
              '- Generate the types for your project and point your type checker at the code.\n'
              '- APIs can still change before the stable release, and feedback on GitHub is very welcome.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Terminal(
              commands: [
                'pip install --pre supabase',
                'supabase gen types --lang python > supabase_schema.py',
              ],
            ),
            SizedBox(height: 56),
            Text(
              'v3 is in alpha, feedback is very welcome',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 40, color: Brand.mutedText),
            ),
            SizedBox(height: 24),
            Text(
              'github.com/supabase/supabase-py',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 40, color: Brand.green),
            ),
          ],
        ),
      ),
    );
  }
}
