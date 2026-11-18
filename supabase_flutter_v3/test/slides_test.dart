// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter_v3/deck_app.dart';

void main() {
  for (final slide in DeckApp.slides) {
    testWidgets('${slide.configuration!.route} renders without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        FlutterDeckApp(
          themeMode: ThemeMode.dark,
          lightTheme: DeckApp.theme,
          darkTheme: DeckApp.theme,
          configuration: DeckApp.configuration,
          slides: [slide],
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
