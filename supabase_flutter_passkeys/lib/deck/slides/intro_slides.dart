import 'package:flutter_deck/flutter_deck.dart';
// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:common/common.dart';

class TitleSlide extends FlutterDeckSlideWidget {
  const TitleSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/intro',
          title: 'Passkeys with supabase_flutter',
          speakerNotes:
              '- Welcome.\n'
              '- Keep your phone handy: at the end you will sign in with a passkey and ask questions live.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.key_rounded, size: 160, color: Brand.green),
            const SizedBox(height: 48),
            const Text(
              'Passkeys with supabase_flutter',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Passwordless sign in for Flutter apps, on Supabase Auth',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 44,
                color: Brand.mutedText.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 64),
            const Pill(
              text: 'Keep your phone ready: the Q&A is passkey protected',
            ),
          ],
        ),
      ),
    );
  }
}

class ProblemSlide extends FlutterDeckSlideWidget {
  const ProblemSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/problem',
          title: 'Passwords are shared secrets',
          speakerNotes:
              '- A password is a secret you hand to the server, and to anyone who can trick you.\n'
              '- Reuse, phishing, leaked databases: all consequences of sharing the secret.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.bigFact(
      title: 'A password is a secret you share',
      subtitle: '...with the server, with its database backups, and with every phishing site that asks nicely.',
    );
  }
}

class WhatIsAPasskeySlide extends FlutterDeckSlideWidget {
  const WhatIsAPasskeySlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/what-is-a-passkey',
          title: 'What is a passkey?',
          steps: 4,
          header: FlutterDeckHeaderConfiguration(title: 'What is a passkey?'),
          speakerNotes:
              '- A WebAuthn / FIDO2 credential: a public/private key pair per account and site.\n'
              '- The server only ever stores the public key. A leak reveals nothing useful.\n'
              '- Bound to the relying party ID (your domain), so a phishing domain cannot use it.\n'
              '- Unlocked with Face ID, fingerprint or the device PIN, synced by the platform password manager.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.split(
      splitRatio: const SplitSlideRatio(left: 3, right: 2),
      leftBuilder: (context) => FlutterDeckBulletList(
        useSteps: true,
        items: const [
          'A key pair per account, created on your device',
          'The server only stores the public key',
          'Bound to your domain, so it cannot be phished',
          'Unlocked with Face ID, fingerprint or PIN',
        ],
      ),
      rightBuilder: (context) => const Center(child: _KeyPairDiagram()),
    );
  }
}

class _KeyPairDiagram extends StatelessWidget {
  const _KeyPairDiagram();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InfoTile(
          icon: Icons.smartphone,
          title: 'Your device',
          text: 'Private key. Never leaves the device or the password manager.',
          highlighted: true,
          direction: Axis.vertical,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Icon(Icons.swap_vert, size: 64, color: Brand.mutedText),
        ),
        InfoTile(
          icon: Icons.dns_outlined,
          title: 'Supabase Auth',
          text: 'Public key. Useless to an attacker on its own.',
          direction: Axis.vertical,
        ),
      ],
    );
  }
}

class RegistrationSlide extends FlutterDeckSlideWidget {
  const RegistrationSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/registration',
          title: 'Registration ceremony',
          steps: 4,
          header: FlutterDeckHeaderConfiguration(title: 'Creating a passkey'),
          speakerNotes:
              '- WebAuthn calls these flows ceremonies.\n'
              '- Supabase hands out a challenge with a challenge id, the device signs it while creating the key.\n'
              '- Supabase verifies the attestation and stores the public key on the user.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NumberedStep(
              number: 1,
              visible: step >= 1,
              title: 'Ask Supabase for creation options',
              text: 'A fresh challenge, the relying party ID and the signed in user.',
            ),
            NumberedStep(
              number: 2,
              visible: step >= 2,
              title: 'The OS prompts the user',
              text: 'Face ID, fingerprint or PIN. The device creates a new key pair.',
            ),
            NumberedStep(
              number: 3,
              visible: step >= 3,
              title: 'Send the public key back',
              text: 'Together with the signed challenge, as a WebAuthn credential.',
            ),
            NumberedStep(
              number: 4,
              visible: step >= 4,
              title: 'Supabase verifies and stores it',
              text: 'The passkey is now attached to the user.',
            ),
          ],
        ),
      ),
    );
  }
}

class AuthenticationSlide extends FlutterDeckSlideWidget {
  const AuthenticationSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/authentication',
          title: 'Authentication ceremony',
          steps: 3,
          header: FlutterDeckHeaderConfiguration(
            title: 'Signing in with a passkey',
          ),
          speakerNotes:
              '- No session needed to start, no username needed either: discoverable credentials.\n'
              '- The signature proves possession of the private key for this exact challenge.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NumberedStep(
              number: 1,
              visible: step >= 1,
              title: 'Ask Supabase for a challenge',
              text: 'No session and no username needed.',
            ),
            NumberedStep(
              number: 2,
              visible: step >= 2,
              title: 'The user picks a passkey and unlocks it',
              text: 'The device signs the challenge with the private key.',
            ),
            NumberedStep(
              number: 3,
              visible: step >= 3,
              title: 'Supabase checks the signature',
              text: 'With the stored public key, and returns a brand new session.',
            ),
          ],
        ),
      ),
    );
  }
}
