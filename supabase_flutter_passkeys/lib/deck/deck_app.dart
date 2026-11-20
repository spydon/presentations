import 'package:common/common.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter_passkeys/deck/slides/code_slides.dart';
import 'package:supabase_flutter_passkeys/deck/slides/crypto_slide.dart';
import 'package:supabase_flutter_passkeys/deck/slides/intro_slides.dart';
import 'package:supabase_flutter_passkeys/deck/slides/qa_slide.dart';
import 'package:supabase_flutter_passkeys/deck/slides/setup_slides.dart';

/// The slides. The last one is the live Q&A.
class DeckApp extends StatelessWidget {
  const DeckApp({super.key});

  static const slides = <FlutterDeckSlideWidget>[
    TitleSlide(),
    SpeakerSlide(),
    ProblemSlide(),
    WhatIsAPasskeySlide(),
    AsymmetricCryptographySlide(),
    RegistrationSlide(),
    AuthenticationSlide(),
    WhoDoesWhatSlide(),
    DashboardSetupSlide(),
    PlatformSetupSlide(),
    InstallSlide(),
    RegisterSlide(),
    SignInSlide(),
    ErrorsSlide(),
    UnderTheHoodSlide(),
    ManageSlide(),
    GotchasSlide(),
    ThisDemoSlide(),
    WithoutTypedApiSlide(),
    QaSlide(),
  ];

  @override
  Widget build(BuildContext context) => const PresentationApp(slides: slides);
}
