import 'package:common/common.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:material_ui/material_ui.dart';

class TitleSlide extends FlutterDeckSlideWidget {
  const TitleSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/intro',
          title: "What's new in supabase_flutter v3",
          footer: FlutterDeckFooterConfiguration(showFooter: false),
          speakerNotes:
              '- Two minutes, two themes.\n'
              '- v3 is built to be written by agents, and it is typed from the database to the widget.',
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
              'supabase_flutter v3',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 120,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Built for agents. Typed end to end.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 52, color: Brand.mutedText),
            ),
            SizedBox(height: 72),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Pill(icon: Icons.smart_toy_outlined, text: 'Package skills'),
                SizedBox(width: 32),
                Pill(icon: Icons.verified_outlined, text: 'Type safety'),
              ],
            ),
          ],
        ),
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
              '- v3 is in beta on pub.dev right now.\n'
              '- Install the skills and let your agent do the migration.\n'
              '- Feedback on GitHub is very welcome before the stable release.',
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
              commands: ['flutter pub add supabase_flutter:^3.0.0-beta'],
            ),
            SizedBox(height: 56),
            Text(
              'Then ask your agent to "migrate this app to supabase_flutter v3 '
              'using the package skills"',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 40, color: Brand.mutedText),
            ),
            SizedBox(height: 24),
            Text(
              'github.com/supabase/supabase-flutter',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 40, color: Brand.green),
            ),
          ],
        ),
      ),
    );
  }
}
