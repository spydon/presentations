import 'package:flutter_deck/flutter_deck.dart';
// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:common/common.dart';

class InstallSlide extends FlutterDeckSlideWidget {
  const InstallSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/install',
          title: 'Install',
          header: FlutterDeckHeaderConfiguration(
            title: 'supabase_flutter v3 + passkeys',
          ),
          speakerNotes:
              '- Passkey support ships in supabase_flutter v3, currently in dev releases.\n'
              '- v3 uses publishableKey instead of anonKey.\n'
              '- supabase_flutter does not depend on a passkey plugin itself, you pick one.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.split(
      leftBuilder: (context) => const Center(
        child: SlideCode(
          language: 'yaml',
          fileName: 'pubspec.yaml',
          code: '''
dependencies:
  supabase_flutter: ^3.0.0-dev.17
  passkeys: ^2.24.2''',
        ),
      ),
      rightBuilder: (context) => const Center(
        child: SlideCode(
          fileName: 'main.dart',
          fontSize: 26,
          code: '''
await Supabase.initialize(
  url: 'https://<ref>.supabase.co',
  publishableKey: 'sb_publishable_...',
);

final supabase = Supabase.instance.client;''',
        ),
      ),
    );
  }
}

class RegisterSlide extends FlutterDeckSlideWidget {
  const RegisterSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/register',
          title: 'Register a passkey',
          steps: 3,
          header: FlutterDeckHeaderConfiguration(title: 'Register a passkey'),
          speakerNotes:
              '- One call runs the whole registration ceremony.\n'
              '- The user must already be signed in, and not anonymous.\n'
              '- The server names the passkey after the authenticator, like iCloud Keychain.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) => Center(
          child: SlideCode(
            fileName: 'register.dart',
            // Zero-indexed line numbers.
            highlightedLines: switch (step) {
              1 => const [0, 2],
              2 => const [4, 5, 6, 7, 8],
              _ => const [10],
            },
            code: '''
import 'package:passkeys/authenticator.dart';

final authenticator = PasskeyAuthenticator();

// Requires a signed in, non-anonymous user.
final passkey = await supabase.auth.registerPasskey(
  authenticator,
  friendlyName: 'Ada',
);

print(passkey.friendlyName); // "iCloud Keychain"''',
          ),
        ),
      ),
    );
  }
}

class SignInSlide extends FlutterDeckSlideWidget {
  const SignInSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/sign-in',
          title: 'Sign in with a passkey',
          header: FlutterDeckHeaderConfiguration(
            title: 'Sign in with a passkey',
          ),
          speakerNotes:
              '- No email, no username: the OS shows the passkeys for this relying party.\n'
              '- Returns the Session directly in v3, and fires AuthSignedIn on onAuthStateChange.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) => const Center(
        child: SlideCode(
          fileName: 'sign_in.dart',
          fontSize: 32,
          code: '''
final session = await supabase.auth.signInWithPasskey(
  authenticator,
);

print('Welcome back \${session.user.id}');''',
        ),
      ),
    );
  }
}

class ErrorsSlide extends FlutterDeckSlideWidget {
  const ErrorsSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/errors',
          title: 'Handling errors',
          header: FlutterDeckHeaderConfiguration(title: 'When things go wrong'),
          speakerNotes:
              '- Errors from the device come from the passkeys plugin.\n'
              '- Errors from the server are AuthApiException with an errorCode.\n'
              '- Cancelling is the most common one: do not show a scary error for it.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) => const Center(
        child: SlideCode(
          fileName: 'sign_in.dart',
          code: '''
try {
  await supabase.auth.signInWithPasskey(authenticator);
} on PasskeyAuthCancelledException {
  // The user closed the prompt, stay quiet.
} on NoCredentialsAvailableException {
  // No passkey for this domain yet, offer to create one.
} on AuthApiException catch (error) {
  // Supabase rejected it, see error.errorCode.
}''',
        ),
      ),
    );
  }
}

class UnderTheHoodSlide extends FlutterDeckSlideWidget {
  const UnderTheHoodSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/under-the-hood',
          title: 'Under the hood',
          steps: 3,
          header: FlutterDeckHeaderConfiguration(
            title: 'Under the hood: auth.passkey',
          ),
          speakerNotes:
              '- registerPasskey is a thin wrapper over the low level API in supabase_auth.\n'
              '- Options and credentials are plain W3C WebAuthn JSON, so any authenticator works.\n'
              '- This is what you use from pure Dart, or with your own platform code.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) => Center(
          child: SlideCode(
            fileName: 'supabase_passkey.dart (simplified)',
            fontSize: 26,
            // Zero-indexed line numbers.
            highlightedLines: switch (step) {
              1 => const [0],
              2 => const [1, 2, 3],
              _ => const [4, 5, 6, 7],
            },
            code: '''
final registration = await supabase.auth.passkey.startRegistration();
final credential = await authenticator.register(
  RegisterRequestType.fromJson(registration.options),
);
await supabase.auth.passkey.verifyRegistration(
  challengeId: registration.challengeId,
  credential: credential.toJson(),
);''',
          ),
        ),
      ),
    );
  }
}

class ManageSlide extends FlutterDeckSlideWidget {
  const ManageSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/manage',
          title: 'Managing passkeys',
          header: FlutterDeckHeaderConfiguration(
            title: 'A passkey settings screen',
          ),
          speakerNotes:
              '- Let users see, rename and remove their passkeys.\n'
              '- With verified MFA factors, the session has to be aal2 to manage passkeys.\n'
              '- Admins can do the same with auth.admin.passkey and the secret key, server side only.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) => const Center(
        child: SlideCode(
          fileName: 'passkey_settings.dart',
          code: '''
final List<Passkey> passkeys = await supabase.auth.passkey.list();

await supabase.auth.passkey.update(
  passkeyId: passkeys.first.id,
  friendlyName: 'Work laptop',
);

await supabase.auth.passkey.delete(passkeyId: passkeys.first.id);''',
        ),
      ),
    );
  }
}

class GotchasSlide extends FlutterDeckSlideWidget {
  const GotchasSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/gotchas',
          title: 'Good to know',
          steps: 5,
          header: FlutterDeckHeaderConfiguration(title: 'Good to know'),
          speakerNotes:
              '- Beta: the API is marked @experimental and can still change.\n'
              '- A passkey is added to an existing user, so sign up still happens another way (OTP, OAuth...). This demo creates a guest user with a generated email.\n'
              '- MFA: aal2 is needed to manage passkeys when factors are verified.\n'
              '  aal1 means one factor (here: the passkey or password), aal2 means a second factor like TOTP was verified in this session, check it with auth.mfa.getAuthenticatorAssuranceLevel().\n'
              '- Changing the relying party ID invalidates every passkey.\n'
              '- Android Restore Credentials: createRestoreKey() and signInWithRestoreKey() give zero tap sign in on a new phone.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.template(
      contentBuilder: (context) => const SteppedBulletList(
        bullets: [
          Bullet('Beta: the API is @experimental and may still change'),
          Bullet('Passkeys are added to a signed in, non-anonymous user'),
          Bullet(
            'With verified MFA factors, managing passkeys needs aal2',
            subBullets: [
              'aal2 = Authenticator Assurance Level 2: the session has also '
                  'passed a second factor, like a TOTP code',
            ],
          ),
          Bullet('The relying party ID is forever, pick your domain carefully'),
          Bullet(
            'Android bonus: createRestoreKey() for zero tap sign in on a new phone',
          ),
        ],
      ),
    );
  }
}

class ThisDemoSlide extends FlutterDeckSlideWidget {
  const ThisDemoSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/this-demo',
          title: 'How the Q&A works',
          header: FlutterDeckHeaderConfiguration(title: 'How this Q&A works'),
          speakerNotes:
              '- One Flutter web build: the slides, and the audience page under ?qa.\n'
              '- Guest user with a generated email, then registerPasskey. The passkey is the only credential.\n'
              '- RLS: anyone reads, only signed in non-anonymous users insert as themselves.\n'
              '- The slide listens with a typed realtime stream().\n'
              '- All of this uses the new typesafe API, a sneak peek of what else is coming in supabase_flutter v3.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.blank(
      builder: (context) => const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SlideCode(
                  fileName: 'ask_page.dart',
                  fontSize: 24,
                  code: '''
await supabase.table(Questions.table).insert(
  QuestionsInsert(
    authorName: name,
    content: content,
  ),
);''',
                ),
              ),
              SizedBox(width: DeckInsets.splitGap),
              Expanded(
                child: SlideCode(
                  fileName: 'live_questions.dart',
                  fontSize: 24,
                  code: '''
final questions = supabase
    .table(Questions.table)
    .stream(primaryKey: [Questions.id])
    .order(Questions.createdAt.desc())
    .limit(50);''',
                ),
              ),
            ],
          ),
          SizedBox(height: 64),
          Pill(
            icon: Icons.auto_awesome,
            text: 'A sneak peek of the new typesafe API in supabase_flutter v3',
          ),
        ],
      ),
    );
  }
}

class WithoutTypedApiSlide extends FlutterDeckSlideWidget {
  const WithoutTypedApiSlide({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/without-typed-api',
          title: 'Without the typesafe API',
          steps: 2,
          header: FlutterDeckHeaderConfiguration(
            title: 'The same Q&A without the typesafe API',
          ),
          speakerNotes:
              '- This is how the same two calls look with the stringly typed from() API.\n'
              '- Table and column names are plain strings, so a typo compiles and fails at runtime.\n'
              '- Rows come back as Map<String, dynamic>: every read needs a cast, and timestamps need parsing by hand.\n'
              '- With the generated schema the compiler catches all of this.',
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckSlide.split(
      leftBuilder: (context) => const ComparisonCode(
        label: 'Writing: a plain map',
        isAfter: false,
        code: '''
await supabase.from('questions').insert({
  'author_name': name,
  'content': content,
});

// A typo like 'autor_name' compiles,
// then fails at runtime.''',
      ),
      rightBuilder: (context) => FlutterDeckSlideStepsBuilder(
        builder: (context, step) => ComparisonCode(
          label: 'Reading: strings and casts',
          isAfter: false,
          visible: step >= 2,
          code: '''
final questions = supabase
    .from('questions')
    .stream(primaryKey: ['id'])
    .order('created_at', ascending: false)
    .limit(50);

// Every row is a Map<String, dynamic>:
final name = row['author_name'] as String;
final createdAt =
    DateTime.parse(row['created_at'] as String);''',
        ),
      ),
    );
  }
}
