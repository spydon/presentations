// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:common/common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter_passkeys/deck/deck_app.dart';
import 'package:supabase_flutter_passkeys/deck/slides/qa_slide.dart';

void main() {
  // The Q&A slide streams from the Supabase project, which the tests do not
  // connect to.
  final slides = DeckApp.slides.where((slide) => slide is! QaSlide);

  for (final slide in slides) {
    testWidgets('${slide.configuration!.route} renders without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(PresentationApp(slides: [slide]));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
