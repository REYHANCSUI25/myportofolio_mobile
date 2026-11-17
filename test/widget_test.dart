import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
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
      await tester.pumpAndSettle();

      expect(find.text('You pressed the ${item.name} button!'), findsOneWidget);
    });
  }

  testWidgets('Add Education opens the education form', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Add Education'));
    await tester.pumpAndSettle();

    expect(find.byType(EducationFormPage), findsOneWidget);
  });

  testWidgets('the drawer replaces the home page with the form', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Add Education'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EducationFormPage), findsOneWidget);
    expect(find.byType(MyHomePage), findsNothing);
  });

  testWidgets('saving an empty form shows what is missing', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));

    await tester.ensureVisible(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Enter the institution.'), findsOneWidget);
    expect(find.text('Enter the degree.'), findsOneWidget);
    expect(find.text('Enter a description.'), findsOneWidget);
    expect(find.text('Choose a start date.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

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
