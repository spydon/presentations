// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:supabase_flutter_passkeys/config.dart';
import 'package:supabase_flutter_passkeys/deck/deck_app.dart';
import 'package:supabase_flutter_passkeys/qa/qa_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: Config.supabaseUrl,
    publishableKey: Config.supabasePublishableKey,
  );

  // The same web build serves both the slides and, under `?qa`, the page the
  // audience opens from the QR code.
  final isQa = Uri.base.queryParameters.containsKey('qa');
  runApp(isQa ? const QaApp() : const DeckApp());
}
