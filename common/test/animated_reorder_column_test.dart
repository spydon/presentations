import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/common.dart';

void main() {
  Widget column(List<String> order) => Directionality(
    textDirection: TextDirection.ltr,
    child: SizedBox(
      height: 400,
      child: AnimatedReorderColumn(
        spacing: 10,
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
        children: [
          for (final id in order)
            SizedBox(key: ValueKey(id), height: id == 'tall' ? 100 : 50),
        ],
      ),
    ),
  );

  double yOf(WidgetTester tester, String id) =>
      tester.getTopLeft(find.byKey(ValueKey(id))).dy;

  testWidgets('slides children to their new place when the order changes', (
    tester,
  ) async {
    await tester.pumpWidget(column(['tall', 'short']));
    expect(yOf(tester, 'tall'), 0);
    expect(yOf(tester, 'short'), 110);

    await tester.pumpWidget(column(['short', 'tall']));
    // The first frame after the change still shows the old positions.
    expect(yOf(tester, 'short'), 110);
    expect(yOf(tester, 'tall'), 0);

    await tester.pump(const Duration(milliseconds: 50));
    expect(yOf(tester, 'short'), closeTo(55, 1));
    expect(yOf(tester, 'tall'), closeTo(30, 1));

    await tester.pumpAndSettle();
    expect(yOf(tester, 'short'), 0);
    expect(yOf(tester, 'tall'), 60);
  });

  testWidgets('new children appear in place', (tester) async {
    await tester.pumpWidget(column(['tall']));
    await tester.pumpWidget(column(['short', 'tall']));
    expect(yOf(tester, 'short'), 0);
    await tester.pumpAndSettle();
    expect(yOf(tester, 'short'), 0);
    expect(yOf(tester, 'tall'), 60);
  });

  testWidgets('removed children fade out while the rest close the gap', (
    tester,
  ) async {
    await tester.pumpWidget(column(['tall', 'short']));
    await tester.pumpWidget(column(['short']));
    // Still there, where it was, but fading.
    expect(yOf(tester, 'tall'), 0);
    await tester.pump(const Duration(milliseconds: 50));
    expect(yOf(tester, 'tall'), 0);
    expect(yOf(tester, 'short'), closeTo(55, 1));
    final fade = tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.byKey(const ValueKey('tall')),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(fade.opacity.value, lessThan(1));
    expect(fade.opacity.value, greaterThan(0));

    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('tall')), findsNothing);
    expect(yOf(tester, 'short'), 0);
  });

  testWidgets('a child that comes back stops fading out', (tester) async {
    await tester.pumpWidget(column(['tall', 'short']));
    await tester.pumpWidget(column(['short']));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(column(['tall', 'short']));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('tall')), findsOneWidget);
    expect(yOf(tester, 'tall'), 0);
    expect(yOf(tester, 'short'), 110);
  });

  testWidgets('is as tall as its children so it can scroll', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            height: 120,
            child: SingleChildScrollView(
              controller: controller,
              child: AnimatedReorderColumn(
                spacing: 10,
                children: [
                  for (final id in ['a', 'b', 'c'])
                    SizedBox(key: ValueKey(id), height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(AnimatedReorderColumn)).height, 320);

    expect(controller.position.maxScrollExtent, 200);

    controller.jumpTo(150);
    await tester.pump();
    expect(tester.getTopLeft(find.byKey(const ValueKey('b'))).dy, -40);
  });
}
