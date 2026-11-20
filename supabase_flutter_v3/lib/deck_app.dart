import 'package:common/common.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter_v3/slides/agent_slides.dart';
import 'package:supabase_flutter_v3/slides/intro_slides.dart';
import 'package:supabase_flutter_v3/slides/passkey_slides.dart';
import 'package:supabase_flutter_v3/slides/type_safety_slides.dart';

class DeckApp extends StatelessWidget {
  const DeckApp({super.key});

  static const slides = <FlutterDeckSlideWidget>[
    TitleSlide(),
    PackageSkillsSlide(),
    TypeSafetySlide(),
    ReadingSlide(),
    WritingSlide(),
    FunctionsSlide(),
    WhyTypesSlide(),
    PasskeysSlide(),
    OutroSlide(),
  ];

  @override
  Widget build(BuildContext context) => const PresentationApp(slides: slides);
}
