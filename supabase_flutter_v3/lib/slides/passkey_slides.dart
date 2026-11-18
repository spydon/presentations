import 'package:common/common.dart';
import 'package:flutter_deck/flutter_deck.dart';
// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

class PasskeysSlide extends FlutterDeckSlideWidget {
  const PasskeysSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/passkeys',
          title: 'Passkeys',
          header: FlutterDeckHeaderConfiguration(
            title: 'One more thing: passkeys',
          ),
          speakerNotes:
              '- v3 adds passkeys: sign in with Face ID, Touch ID or a security key, no password.\n'
              '- supabase_flutter runs the server side of the WebAuthn ceremony, the authenticator shows the platform prompt.\n'
              '- It does not depend on a passkey plugin itself. The passkeys package works out of the box, or bring your own.\n'
              '- On Android, restore keys sign the user back in on a new phone without any prompt.\n'
              '- Passkeys are in beta, enable them in the dashboard under Authentication.\n'
              '- There is a whole talk on this: spydon.github.io/passkeys_presentation',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.split(
      splitRatio: const SplitSlideRatio(left: 3, right: 2),
      leftBuilder: (context) => const Align(
        alignment: Alignment.centerLeft,
        child: SlideCode(
          fontSize: 26,
          code: '''
import 'package:passkeys/authenticator.dart';

final authenticator = PasskeyAuthenticator();

// Registers a passkey for the signed in user.
final Passkey passkey =
    await supabase.auth.registerPasskey(authenticator);

// Face ID, Touch ID or a security key, no password.
final Session session =
    await supabase.auth.signInWithPasskey(authenticator);''',
        ),
      ),
      rightBuilder: (context) => const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InfoTile(
            icon: Icons.fingerprint,
            title: 'No passwords',
            text: 'Nothing to leak, reuse or phish.',
          ),
          SizedBox(height: 32),
          InfoTile(
            icon: Icons.extension_outlined,
            title: 'Bring your own plugin',
            text: 'Works with the passkeys package, or any authenticator.',
          ),
          SizedBox(height: 32),
          InfoTile(
            icon: Icons.phone_android,
            title: 'Restore Credentials',
            text: 'Signs users back in on a new Android phone.',
          ),
        ],
      ),
    );
  }
}
