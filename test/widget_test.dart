import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/education_detail.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/education_list.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/login.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/item_card.dart';
import 'package:provider/provider.dart';

import 'fake_backend.dart';

Future<void> pumpApp(WidgetTester tester, FakeBackend backend) async {
  await tester.pumpWidget(MyApp(apiClient: backend.client));
}

void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> openDrawer(WidgetTester tester) async {
  tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
  await tester.pumpAndSettle();
}

Finder inDrawer(String text) {
  return find.descendant(of: find.byType(Drawer), matching: find.text(text));
}

Future<void> tapDrawerItem(WidgetTester tester, String title) async {
  await tester.tap(inDrawer(title));
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

Future<void> logIn(
  WidgetTester tester, {
  String password = FakeBackend.password,
}) async {
  await tester.enterText(fieldLabelled('Username'), FakeBackend.username);
  await tester.enterText(fieldLabelled('Password'), password);
  await tester.tap(find.text('Log in'));
  await tester.pumpAndSettle();
}

Future<void> logInFromDrawer(WidgetTester tester) async {
  await openDrawer(tester);
  await tapDrawerItem(tester, 'Login');
  await logIn(tester);
}

Future<void> openEducationFormAndLogIn(WidgetTester tester) async {
  await tester.tap(find.text('Add Education'));
  await tester.pumpAndSettle();
  await logIn(tester);
}

Future<void> fillEducationForm(WidgetTester tester) async {
  await tester.enterText(fieldLabelled('Institution'), 'Test University');
  await tester.enterText(fieldLabelled('Degree'), 'Bachelor of Testing');
  await tester.enterText(fieldLabelled('Description'), 'Wrote widget tests.');
  await tester.ensureVisible(find.text('Start Date'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Start Date'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('15'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> openEducationList(WidgetTester tester) async {
  await tester.tap(find.text('View Education'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows my NPM, full name and PBP class', (tester) async {
    await pumpApp(tester, FakeBackend());

    expect(find.text('2506637086'), findsOneWidget);
    expect(find.text('Muhammad Reyhan Attarizky'), findsOneWidget);
    expect(find.text('PBP KI'), findsOneWidget);
  });

  testWidgets('gives each action button its own color', (tester) async {
    await pumpApp(tester, FakeBackend());

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

  for (final item in MyHomePage.items.where((entry) => !entry.logsOut)) {
    testWidgets('pressing ${item.name} shows its snackbar', (tester) async {
      await pumpApp(tester, FakeBackend());

      await tester.tap(find.text(item.name));
      await tester.pumpAndSettle();

      expect(find.text('You pressed the ${item.name} button!'), findsOneWidget);
    });
  }

  testWidgets('Add Education asks you to log in first', (tester) async {
    await pumpApp(tester, FakeBackend());

    await tester.tap(find.text('Add Education'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(EducationFormPage), findsNothing);

    await logIn(tester, password: 'wrong-password');

    expect(
      find.text(
        'Login failed (400): Unable to log in with provided credentials.',
      ),
      findsOneWidget,
    );
    expect(find.byType(LoginPage), findsOneWidget);

    await logIn(tester);

    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(EducationFormPage), findsOneWidget);
  });

  testWidgets('the login page asks for both fields', (tester) async {
    final FakeBackend backend = FakeBackend();
    await pumpApp(tester, backend);
    await tester.tap(find.text('Add Education'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your username.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(backend.requests, isEmpty);
  });

  testWidgets('the drawer opens the education form after you log in', (
    tester,
  ) async {
    await pumpApp(tester, FakeBackend());

    await openDrawer(tester);
    await tapDrawerItem(tester, 'Add Education');

    expect(find.byType(LoginPage), findsOneWidget);

    await logIn(tester);

    expect(find.byType(EducationFormPage), findsOneWidget);
  });

  testWidgets('once you are logged in, Add Education skips the login', (
    tester,
  ) async {
    await pumpApp(tester, FakeBackend());
    await logInFromDrawer(tester);

    await tester.tap(find.text('Add Education'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(EducationFormPage), findsOneWidget);
  });

  testWidgets('Login and Logout in the drawer follow the login state', (
    tester,
  ) async {
    final FakeBackend backend = FakeBackend();
    await pumpApp(tester, backend);

    await openDrawer(tester);
    expect(inDrawer('Logout'), findsNothing);
    await tapDrawerItem(tester, 'Login');
    await logIn(tester);

    expect(find.text('Logged in as owner.'), findsOneWidget);

    await openDrawer(tester);
    expect(inDrawer('Login'), findsNothing);
    expect(inDrawer('Logged in as owner'), findsOneWidget);
    await tapDrawerItem(tester, 'Logout');

    expect(find.text("You've been logged out."), findsOneWidget);
    final http.Request logout = backend.requestsTo('POST', logoutPath).single;
    expect(logout.headers['Authorization'], 'Token token-1');

    await openDrawer(tester);
    expect(inDrawer('Login'), findsOneWidget);
  });

  testWidgets('the Logout button logs you out', (tester) async {
    final FakeBackend backend = FakeBackend();
    await pumpApp(tester, backend);
    await logInFromDrawer(tester);

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text("You've been logged out."), findsOneWidget);
    expect(backend.requestsTo('POST', logoutPath), hasLength(1));
    final BuildContext context = tester.element(find.byType(MyHomePage));
    expect(context.read<AuthState>().isLoggedIn, isFalse);
  });

  testWidgets('the Logout button says so when you are not logged in', (
    tester,
  ) async {
    final FakeBackend backend = FakeBackend();
    await pumpApp(tester, backend);

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text("You aren't logged in."), findsOneWidget);
    expect(backend.requests, isEmpty);
  });

  testWidgets('View Education lists the entries without a login', (
    tester,
  ) async {
    final FakeBackend backend = FakeBackend();
    await pumpApp(tester, backend);

    await openEducationList(tester);

    expect(find.byType(EducationListPage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
    expect(find.text('S1 Ilmu Komputer KKI'), findsOneWidget);
    expect(find.text('Universitas Indonesia'), findsOneWidget);
    expect(find.text('August 2025 – Present'), findsOneWidget);
    expect(backend.requestsTo('GET', educationPath), hasLength(1));
  });

  testWidgets('a failed load explains why and Retry loads again', (
    tester,
  ) async {
    final FakeBackend backend = FakeBackend()..listStatus = 500;
    await pumpApp(tester, backend);

    await openEducationList(tester);

    expect(find.text("Couldn't load the education entries."), findsOneWidget);
    expect(find.text('The server had a problem.'), findsOneWidget);

    backend.listStatus = 200;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('S1 Ilmu Komputer KKI'), findsOneWidget);
    expect(backend.requestsTo('GET', educationPath), hasLength(2));
  });

  testWidgets('the list says when the server cannot be reached', (
    tester,
  ) async {
    final FakeBackend backend = FakeBackend()..offline = true;
    await pumpApp(tester, backend);

    await openEducationList(tester);

    expect(
      find.text("Couldn't reach the server. Check that Django is running."),
      findsOneWidget,
    );
  });

  testWidgets('an empty list says there are no entries yet', (tester) async {
    final FakeBackend backend = FakeBackend();
    backend.entries.clear();
    await pumpApp(tester, backend);

    await openDrawer(tester);
    await tapDrawerItem(tester, 'View Education');

    expect(find.text('No education entries yet.'), findsOneWidget);
  });

  testWidgets('pulling the list down loads it again', (tester) async {
    final FakeBackend backend = FakeBackend();
    await pumpApp(tester, backend);
    await openEducationList(tester);

    backend.entries.add(educationJson(id: 'second', degree: 'Second Degree'));
    await tester.fling(
      find.text('S1 Ilmu Komputer KKI'),
      const Offset(0, 300),
      1000,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Second Degree'), findsOneWidget);
    expect(backend.requestsTo('GET', educationPath), hasLength(2));
  });

  testWidgets('tapping an entry opens its details', (tester) async {
    await pumpApp(tester, FakeBackend());
    await openEducationList(tester);

    await tester.tap(find.text('S1 Ilmu Komputer KKI'));
    await tester.pumpAndSettle();

    expect(find.byType(EducationDetailPage), findsOneWidget);
    expect(find.text('Ongoing'), findsOneWidget);
    expect(find.text('Aug 1, 2025'), findsOneWidget);
    expect(find.text('End date'), findsNothing);
    expect(find.text('Studying computer science.'), findsOneWidget);
  });

  testWidgets('a finished entry shows its end date instead', (tester) async {
    final FakeBackend backend = FakeBackend();
    backend.entries[0] = educationJson(endedAt: '2029-07-31');
    await pumpApp(tester, backend);
    await openEducationList(tester);

    expect(find.text('August 2025 – July 2029'), findsOneWidget);

    await tester.tap(find.text('S1 Ilmu Komputer KKI'));
    await tester.pumpAndSettle();

    expect(find.text('Ongoing'), findsNothing);
    expect(find.text('End date'), findsOneWidget);
    expect(find.text('Jul 31, 2029'), findsOneWidget);
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

  testWidgets('saving a valid entry posts it with your token', (tester) async {
    usePhoneScreen(tester);
    final FakeBackend backend = FakeBackend();
    await pumpApp(tester, backend);
    await openEducationFormAndLogIn(tester);

    await fillEducationForm(tester);
    await tapSave(tester);

    final http.Request post = backend.requestsTo('POST', educationPath).single;
    expect(post.headers['Authorization'], 'Token token-1');
    final Map<String, dynamic> body = jsonBody(post);
    expect(body.keys.toSet(), {
      'institution',
      'degree',
      'description',
      'started_at',
      'ended_at',
    });
    expect(body['institution'], 'Test University');
    expect(body['started_at'], endsWith('-15'));
    expect(body['ended_at'], isNull);

    expect(find.text('Education entry added successfully!'), findsOneWidget);
    expect(find.text('Institution: Test University'), findsOneWidget);
    expect(find.text('Degree: Bachelor of Testing'), findsOneWidget);
    expect(find.text('Description: Wrote widget tests.'), findsOneWidget);
    expect(
      find.textContaining(RegExp(r'^Start date: \w{3} 15, \d{4}$')),
      findsOneWidget,
    );
    expect(find.text('End date: Present'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(EducationFormPage), findsOneWidget);
    expect(find.text('Test University'), findsNothing);
  });

  testWidgets('an expired token asks you to log in again, then saves', (
    tester,
  ) async {
    usePhoneScreen(tester);
    final FakeBackend backend = FakeBackend();
    await pumpApp(tester, backend);
    await openEducationFormAndLogIn(tester);
    await fillEducationForm(tester);
    backend.expireTokens();

    await tapSave(tester);

    expect(find.byType(LoginPage), findsOneWidget);

    await logIn(tester);

    expect(find.text('Education entry added successfully!'), findsOneWidget);
    final List<http.Request> posts = backend.requestsTo('POST', educationPath);
    expect(posts, hasLength(2));
    expect(posts.first.headers['Authorization'], 'Token token-1');
    expect(posts.last.headers['Authorization'], 'Token token-2');
  });

  testWidgets('Add Experience opens the experience form', (tester) async {
    await pumpApp(tester, FakeBackend());

    await tester.tap(find.text('Add Experience'));
    await tester.pumpAndSettle();

    expect(find.byType(ExperienceFormPage), findsOneWidget);
  });

  testWidgets('the drawer opens the experience form above the home screen', (
    tester,
  ) async {
    await pumpApp(tester, FakeBackend());

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
    await pumpApp(tester, FakeBackend());
    await tester.tap(find.text('Add Experience'));
    await tester.pumpAndSettle();

    await openDrawer(tester);
    await tapDrawerItem(tester, 'Home');

    expect(find.byType(ExperienceFormPage), findsNothing);
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(rootNavigator(tester).canPop(), isFalse);
  });

  testWidgets('the drawer marks the page you are on', (tester) async {
    await pumpApp(tester, FakeBackend());

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
    await pumpApp(tester, FakeBackend());
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
    await pumpApp(tester, FakeBackend());
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

    await pumpApp(tester, FakeBackend());

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

    await pumpApp(tester, FakeBackend());

    final BuildContext context = tester.element(find.byType(MyHomePage));
    expect(Theme.of(context).brightness, Brightness.dark);
  });
}
