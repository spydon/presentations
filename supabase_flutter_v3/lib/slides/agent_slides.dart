import 'package:common/common.dart';
import 'package:flutter_deck/flutter_deck.dart';
// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

class TrainedOnV2Slide extends FlutterDeckSlideWidget {
  const TrainedOnV2Slide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/trained-on-v2',
          title: 'Your agent was trained on v2',
          speakerNotes:
              '- Every model out there learned supabase_flutter from years of v2 examples.\n'
              '- Ask it to write v3 code and it confidently writes v2 code that does not compile.\n'
              '- So v3 ships the knowledge together with the package.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.bigFact(
      title: 'Your agent was trained on v2',
      subtitle:
          'So it confidently writes code that no longer compiles. '
          'v3 ships the fix inside the package.',
    );
  }
}

class PackageSkillsSlide extends FlutterDeckSlideWidget {
  const PackageSkillsSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/package-skills',
          title: 'Package skills',
          steps: 3,
          header: FlutterDeckHeaderConfiguration(
            title: 'Step one: install the package skills',
          ),
          speakerNotes:
              '- Package skills are instructions for Claude Code, Cursor, Codex, Gemini and Copilot, versioned with the package.\n'
              '- supabase_flutter: migrating from v2, the current idioms, auth setup and realtime.\n'
              '- supabase_typegen: how to run the Supabase CLI to generate the Dart types, and keep them in sync after every migration.\n'
              '- supabase_test: fast tests against a real client, stubbed HTTP and in-memory realtime, no running stack.\n'
              '- Run them again after every upgrade so the skills follow the package.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Terminal(
              step: step,
              commands: const [
                'dart run skills@ get -p supabase_flutter',
                'dart run skills@ get -p supabase_typegen',
                'dart run skills@ get -p supabase_test',
              ],
            ),
            const SizedBox(height: 48),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InfoTile(
                    icon: Icons.upgrade,
                    title: 'Migrate',
                    text:
                        'Moves a v2 app to v3 and writes current v3 code, '
                        'not what the model remembers.',
                    highlighted: step == 1,
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: InfoTile(
                    icon: Icons.schema_outlined,
                    title: 'Generate types',
                    text:
                        'Runs the Supabase CLI to generate Dart types '
                        'from your schema, and keeps them in sync.',
                    highlighted: step == 2,
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: InfoTile(
                    icon: Icons.science_outlined,
                    title: 'Test',
                    text:
                        'Writes fast tests with stubbed requests and '
                        'in-memory realtime. No running stack.',
                    highlighted: step == 3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
