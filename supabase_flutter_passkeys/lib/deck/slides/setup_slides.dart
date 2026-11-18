import 'package:flutter_deck/flutter_deck.dart';
// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:common/common.dart';

class WhoDoesWhatSlide extends FlutterDeckSlideWidget {
  const WhoDoesWhatSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/who-does-what',
          title: 'Who does what',
          header: FlutterDeckHeaderConfiguration(title: 'Three moving parts'),
          speakerNotes:
              '- Supabase Auth is the relying party server: challenges, verification, storage.\n'
              '- supabase_flutter glues the two ceremonies together.\n'
              '- The passkeys plugin (Corbado) talks to the OS. supabase_flutter only depends on its interface.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) => const Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: InfoTile(
                icon: Icons.dns_outlined,
                title: 'Supabase Auth',
                text:
                    'The relying party. Issues challenges, verifies credentials, '
                    'stores public keys and creates sessions.',
                direction: Axis.vertical,
              ),
            ),
            SizedBox(width: 32),
            Expanded(
              child: InfoTile(
                icon: Icons.flutter_dash,
                title: 'supabase_flutter',
                text:
                    'registerPasskey() and signInWithPasskey() run the whole '
                    'ceremony for you.',
                highlighted: true,
                direction: Axis.vertical,
              ),
            ),
            SizedBox(width: 32),
            Expanded(
              child: InfoTile(
                icon: Icons.fingerprint,
                title: 'passkeys plugin',
                text:
                    'PasskeyAuthenticator shows the OS prompt on Android, iOS, '
                    'macOS, Windows and web.',
                direction: Axis.vertical,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardSetupSlide extends FlutterDeckSlideWidget {
  const DashboardSetupSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/dashboard',
          title: 'Enable passkeys',
          steps: 3,
          header: FlutterDeckHeaderConfiguration(title: 'Step 0: turn it on'),
          speakerNotes:
              '- Passkeys are in beta in Supabase Auth, so they are off by default.\n'
              '- The relying party ID is the domain the passkeys are bound to. Get it right before users create passkeys, changing it invalidates them.\n'
              '- Without it, the options endpoint answers 404 passkey_disabled.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.split(
      leftBuilder: (context) => FlutterDeckBulletList(
        useSteps: true,
        items: const [
          'Dashboard: Authentication > Configuration > Passkeys (beta)',
          'Set the relying party ID to your domain',
          'Allow the origins your app runs on',
        ],
      ),
      rightBuilder: (context) => const Center(
        child: SlideCode(
          language: 'json',
          fileName: 'POST /auth/v1/passkeys/authentication/options',
          code: '''
{
  "code": 404,
  "error_code": "passkey_disabled",
  "msg": "Passkeys are disabled"
}''',
        ),
      ),
    );
  }
}

class PlatformSetupSlide extends FlutterDeckSlideWidget {
  const PlatformSetupSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/platforms',
          title: 'Platform setup',
          header: FlutterDeckHeaderConfiguration(
            title: 'Prove that the app owns the domain',
          ),
          speakerNotes:
              '- This is the part that takes the longest the first time.\n'
              '- Web: the passkeys_web JS bundle in index.html, HTTPS (localhost is fine for development).\n'
              '- Apple: Associated Domains with the webcredentials: prefix and an apple-app-site-association file.\n'
              '- Android: assetlinks.json with the get_login_creds permission.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) => const Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: InfoTile(
                icon: Icons.language,
                title: 'Web',
                text:
                    'Load the passkeys_web bundle.js in index.html. '
                    'Serve over HTTPS on the relying party domain.',
                direction: Axis.vertical,
              ),
            ),
            SizedBox(width: 32),
            Expanded(
              child: InfoTile(
                icon: Icons.apple,
                title: 'iOS and macOS',
                text:
                    'Associated Domains entitlement webcredentials:example.com '
                    'and /.well-known/apple-app-site-association.',
                direction: Axis.vertical,
              ),
            ),
            SizedBox(width: 32),
            Expanded(
              child: InfoTile(
                icon: Icons.android,
                title: 'Android',
                text:
                    '/.well-known/assetlinks.json with '
                    'delegate_permission/common.get_login_creds.',
                direction: Axis.vertical,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
