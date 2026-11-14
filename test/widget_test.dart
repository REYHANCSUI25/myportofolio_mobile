import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/menu.dart';
import 'package:myportofolio_mobile/widgets/item_card.dart';

void main() {
  testWidgets('shows my NPM, full name and PBP class', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('2506637086'), findsOneWidget);
    expect(find.text('Muhammad Reyhan Attarizky'), findsOneWidget);
    expect(find.text('PBP KI'), findsOneWidget);
  });

  testWidgets('gives each action button its own color', (tester) async {
    await tester.pumpWidget(const MyApp());

    for (final item in MyHomePage.items) {
      final Material tile = tester.widget<Material>(
        find.descendant(
          of: find.widgetWithText(ItemCard, item.name),
          matching: find.byType(Material),
        ),
      );
      expect(tile.color, item.color);
    }
    expect(
      MyHomePage.items.map((item) => item.color).toSet(),
      hasLength(MyHomePage.items.length),
    );
  });

  for (final item in MyHomePage.items) {
    testWidgets('pressing ${item.name} shows its snackbar', (tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text(item.name));
      await tester.pump();

      expect(find.text('You pressed the ${item.name} button!'), findsOneWidget);
    });
  }

  testWidgets('fits a small phone screen without overflowing', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());

    expect(tester.takeException(), isNull);
  });

  testWidgets('follows the system dark mode', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const MyApp());

    final BuildContext context = tester.element(find.byType(MyHomePage));
    expect(Theme.of(context).brightness, Brightness.dark);
  });
}
