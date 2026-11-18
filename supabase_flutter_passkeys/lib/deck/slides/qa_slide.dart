import 'package:flutter_deck/flutter_deck.dart';
// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:supabase_flutter_passkeys/config.dart';
import 'package:supabase_flutter_passkeys/deck/widgets/live_questions.dart';
import 'package:supabase_flutter_passkeys/deck/widgets/passkey_counter.dart';
import 'package:common/common.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QaSlide extends FlutterDeckSlideWidget {
  const QaSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/qa',
          title: 'Q&A',
          showProgress: false,
          speakerNotes:
              '- Scan, pick a name, create a passkey, ask.\n'
              '- Questions appear here in real time, newest on top with a green border.\n'
              '- Delete bad ones from the Supabase dashboard if needed.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    final url = Config.qaUrl;
    return FlutterDeckSlide.blank(
      builder: (context) => Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 620,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Questions?',
                  style: TextStyle(fontSize: 88, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Scan, create a passkey, ask.',
                  style: TextStyle(fontSize: 38, color: Brand.mutedText),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: QrImageView(
                    data: url,
                    size: 420,
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  ),
                ),
                const SizedBox(height: 28),
                SelectableText(
                  url.replaceFirst(RegExp('^https?://'), ''),
                  style: const TextStyle(fontSize: 28, color: Brand.green),
                ),
                const SizedBox(height: 48),
                const PasskeyCounter(),
              ],
            ),
          ),
          const SizedBox(width: 64),
          const Expanded(child: LiveQuestions()),
        ],
      ),
    );
  }
}
