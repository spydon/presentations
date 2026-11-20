import 'package:material_ui/material_ui.dart';
import 'package:common/common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_py_v3/deck_app.dart';

void main() {
  for (final slide in DeckApp.slides) {
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
