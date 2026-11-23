import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/widgets/item_card.dart';

Future<void> openDrawer(WidgetTester tester) async {
  tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
  await tester.pumpAndSettle();
}

Future<void> tapDrawerItem(WidgetTester tester, String title) async {
  await tester.tap(
    find.descendant(of: find.byType(Drawer), matching: find.text(title)),
  );
  await tester.pumpAndSettle();
}

Future<void> tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

Finder fieldLabelled(String label) {
  return find.widgetWithText(TextFormField, label);
}

NavigatorState rootNavigator(WidgetTester tester) {
  return tester.state<NavigatorState>(find.byType(Navigator));
}

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

  testWidgets('the drawer opens the education form', (tester) async {
    await tester.pumpWidget(const MyApp());

    await openDrawer(tester);
    await tapDrawerItem(tester, 'Add Education');

    expect(find.byType(EducationFormPage), findsOneWidget);
  });

  testWidgets('saving an empty education form shows what is missing', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));

    await tapSave(tester);

    expect(find.text('Enter the institution.'), findsOneWidget);
    expect(find.text('Enter the degree.'), findsOneWidget);
    expect(find.text('Enter a description.'), findsOneWidget);
    expect(find.text('Choose a start date.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Add Experience opens the experience form', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Add Experience'));
    await tester.pumpAndSettle();

    expect(find.byType(ExperienceFormPage), findsOneWidget);
  });

  testWidgets('the drawer opens the experience form above the home screen', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await openDrawer(tester);
    await tapDrawerItem(tester, 'Add Experience');

    expect(find.byType(ExperienceFormPage), findsOneWidget);

    rootNavigator(tester).maybePop();
    await tester.pumpAndSettle();

    expect(find.byType(ExperienceFormPage), findsNothing);
    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets('Home in the drawer takes a form back to the home screen', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Add Experience'));
    await tester.pumpAndSettle();

    await openDrawer(tester);
    await tapDrawerItem(tester, 'Home');

    expect(find.byType(ExperienceFormPage), findsNothing);
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(rootNavigator(tester).canPop(), isFalse);
  });

  testWidgets('the drawer marks the page you are on', (tester) async {
    await tester.pumpWidget(const MyApp());

    await openDrawer(tester);

    final ListTile home = tester.widget<ListTile>(
      find.widgetWithText(ListTile, 'Home'),
    );
    final ListTile addExperience = tester.widget<ListTile>(
      find.widgetWithText(ListTile, 'Add Experience'),
    );
    expect(home.selected, isTrue);
    expect(addExperience.selected, isFalse);
  });

  testWidgets('an invalid experience shows an error next to each field', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));

    await tester.enterText(fieldLabelled('Title'), '   ');
    await tester.enterText(fieldLabelled('Thumbnail URL'), 'not a link');
    await tapSave(tester);

    expect(find.text('Enter a title.'), findsOneWidget);
    expect(find.text('Enter a description.'), findsOneWidget);
    expect(
      find.text('Enter a valid link that starts with http:// or https://.'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('a valid experience is summarized in a dialog', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));

    await tester.enterText(fieldLabelled('Title'), 'Teaching Assistant');
    await tester.enterText(fieldLabelled('Description'), 'Graded weekly labs.');
    await tester.enterText(
      fieldLabelled('Thumbnail URL'),
      'https://example.com/ta.png',
    );
    await tapSave(tester);

    expect(find.text('Title: Teaching Assistant'), findsOneWidget);
    expect(find.text('Category: Full-Time'), findsOneWidget);
    expect(find.text('Description: Graded weekly labs.'), findsOneWidget);
    expect(find.text('Thumbnail: https://example.com/ta.png'), findsOneWidget);
    expect(find.text('End date: Ongoing'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(ExperienceFormPage), findsOneWidget);
    expect(find.text('Teaching Assistant'), findsNothing);
  });

  testWidgets('going back with unsaved input asks before discarding it', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Add Experience'));
    await tester.pumpAndSettle();

    await tester.enterText(fieldLabelled('Title'), 'Draft');
    await tester.pump();
    rootNavigator(tester).maybePop();
    await tester.pumpAndSettle();

    expect(find.text('Discard this entry?'), findsOneWidget);

    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    expect(find.byType(ExperienceFormPage), findsNothing);
    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets('leaving through the drawer with unsaved input asks first', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Add Experience'));
    await tester.pumpAndSettle();

    await tester.enterText(fieldLabelled('Title'), 'Draft');
    await tester.pump();
    await openDrawer(tester);
    await tapDrawerItem(tester, 'Home');

    expect(find.text('Discard this entry?'), findsOneWidget);

    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();

    expect(find.byType(ExperienceFormPage), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
  });

  testWidgets('fits a small phone screen without overflowing', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());

    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps Save reachable on a small phone with the keyboard open', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));
    await tapSave(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Enter a title.'), findsOneWidget);
  });

  testWidgets('follows the system dark mode', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const MyApp());

    final BuildContext context = tester.element(find.byType(MyHomePage));
    expect(Theme.of(context).brightness, Brightness.dark);
  });
}
