import 'package:common/common.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// A thank you to Corbado, who made the passkeys package.
class CorbadoSlide extends FlutterDeckSlideWidget {
  const CorbadoSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/corbado',
          title: 'Thank you, Corbado',
          header: FlutterDeckHeaderConfiguration(title: 'Thank you, Corbado'),
          speakerNotes:
              '- The passkeys package is made by Corbado.\n'
              '- It does the hard, platform specific part: talking to the OS '
              'passkey APIs on every platform.\n'
              '- Thanks to it, supabase_flutter only needs to depend on an '
              'interface.',
        ),
      );

  static const url = 'https://pub.dev/packages/passkeys';

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) => Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PopIn(
                  child: SvgPicture.asset(
                    'assets/images/corbado_logo.svg',
                    height: 160,
                    semanticsLabel: 'Corbado',
                    // The logo is drawn in black for light backgrounds.
                    colorFilter: const ColorFilter.mode(
                      Brand.text,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 56),
                const Text(
                  'They made the passkeys package.',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'It shows the OS passkey prompt on Android, iOS, macOS, '
                  'Windows and web, so supabase_flutter does not have to.',
                  style: TextStyle(
                    fontSize: 34,
                    color: Brand.mutedText,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 48),
                const Pill(
                  icon: Icons.link_rounded,
                  text: 'pub.dev/packages/passkeys',
                ),
              ],
            ),
          ),
          const SizedBox(width: 120),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: QrImageView(
                  data: url,
                  size: 380,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Scan to open on pub.dev',
                style: TextStyle(fontSize: 28, color: Brand.mutedText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
