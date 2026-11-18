import 'package:flutter_deck/flutter_deck.dart';
// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:supabase_flutter_v3/brand.dart';
import 'package:supabase_flutter_v3/slides/agent_slides.dart';
import 'package:supabase_flutter_v3/slides/intro_slides.dart';
import 'package:supabase_flutter_v3/slides/type_safety_slides.dart';
import 'package:supabase_flutter_v3/widgets/deck_templates.dart';

class DeckApp extends StatelessWidget {
  const DeckApp({super.key});

  static const slides = <FlutterDeckSlideWidget>[
    TitleSlide(),
    TrainedOnV2Slide(),
    PackageSkillsSlide(),
    TypeSafetySlide(),
    ReadingSlide(),
    WritingSlide(),
    WhyTypesSlide(),
    OutroSlide(),
  ];

  static FlutterDeckThemeData get theme {
    final baseTheme = FlutterDeckThemeData(theme: Brand.theme);
    return baseTheme.copyWith(
      bulletListTheme: baseTheme.bulletListTheme.copyWith(
        textStyle: const TextStyle(
          fontFamily: 'Outfit',
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
