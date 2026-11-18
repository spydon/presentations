import 'package:common/src/brand.dart';
import 'package:common/src/deck_templates.dart';
import 'package:flutter_deck/flutter_deck.dart';
// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A [FlutterDeckApp] with the theme and configuration shared by the
/// presentations: 1080p slides, a dark Supabase theme and wider margins.
class PresentationApp extends StatelessWidget {
  const PresentationApp({required this.slides, super.key});

  final List<FlutterDeckSlideWidget> slides;

  static FlutterDeckThemeData get theme {
    final baseTheme = FlutterDeckThemeData(theme: Brand.theme);
    return baseTheme.copyWith(
      bulletListTheme: baseTheme.bulletListTheme.copyWith(
        textStyle: const TextStyle(
          fontFamily: Brand.fontFamily,
          fontSize: 44,
          height: 1.3,
          fontVariations: [FontVariation.weight(400)],
        ),
      ),
    );
  }

  static FlutterDeckConfiguration get configuration => FlutterDeckConfiguration(
    background: const FlutterDeckBackgroundConfiguration(
      light: FlutterDeckBackground.solid(Brand.background),
      dark: FlutterDeckBackground.gradient(
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1C1C), Color(0xFF14261D)],
        ),
      ),
    ),
    controls: const FlutterDeckControlsConfiguration(
      shortcuts: FlutterDeckShortcutsConfiguration(
        nextSlide: {
          SingleActivator(LogicalKeyboardKey.arrowRight),
          SingleActivator(LogicalKeyboardKey.keyL),
        },
        previousSlide: {
          SingleActivator(LogicalKeyboardKey.arrowLeft),
          SingleActivator(LogicalKeyboardKey.keyH),
        },
      ),
    ),
    footer: const FlutterDeckFooterConfiguration(showSlideNumbers: true),
    progressIndicator: const FlutterDeckProgressIndicator.solid(
      color: Brand.green,
      backgroundColor: Brand.surface,
    ),
    slideSize: FlutterDeckSlideSize.fromAspectRatio(
      aspectRatio: const FlutterDeckAspectRatio.ratio16x9(),
      resolution: const FlutterDeckResolution.fhd(),
    ),
    templateOverrides: deckTemplateOverrides,
    transition: const FlutterDeckTransition.fade(),
  );

  @override
  Widget build(BuildContext context) {
    return FlutterDeckApp(
      themeMode: ThemeMode.dark,
      lightTheme: theme,
      darkTheme: theme,
      configuration: configuration,
      slides: slides,
    );
  }
}
