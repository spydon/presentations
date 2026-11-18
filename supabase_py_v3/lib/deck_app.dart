import 'package:common/common.dart';
import 'package:flutter_deck/flutter_deck.dart';
// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:supabase_py_v3/slides/intro_slides.dart';
import 'package:supabase_py_v3/slides/type_safety_slides.dart';

class DeckApp extends StatelessWidget {
  const DeckApp({super.key});

  static const slides = <FlutterDeckSlideWidget>[
    TitleSlide(),
    TypeSafetySlide(),
    ReadingSlide(),
    WritingSlide(),
    FunctionsSlide(),
    WhyTypesSlide(),
    OutroSlide(),
  ];

  @override
  Widget build(BuildContext context) => const PresentationApp(slides: slides);
}
