import 'dart:async';

// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:supabase_flutter_passkeys/qa/ask_page.dart';
import 'package:supabase_flutter_passkeys/qa/login_page.dart';
import 'package:supabase_flutter_passkeys/qa/passkey_auth.dart';
import 'package:common/common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The page the audience opens from the QR code on the Q&A slide.
class QaApp extends StatelessWidget {
  const QaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passkey Q&A',
      debugShowCheckedModeBanner: false,
      theme: Brand.theme,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  final _auth = Supabase.instance.client.auth;
  late final StreamSubscription<AuthState> _subscription;
  late Session? _session = _auth.currentSession;

  @override
  void initState() {
    super.initState();
    _subscription = _auth.onAuthStateChange.listen(
      (state) => setState(() => _session = _auth.currentSession),
      onError: (Object _) => setState(() => _session = _auth.currentSession),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: accountSetupInProgress,
      builder: (context, settingUp, _) {
        final session = _session;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: session == null || settingUp
              ? const LoginPage(key: ValueKey('login'))
              : AskPage(key: ValueKey(session.user.id), user: session.user),
        );
      },
    );
  }
}
