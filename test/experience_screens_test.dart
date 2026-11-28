import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_detail.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/experience_list.dart';
import 'package:myportofolio_mobile/screens/login.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

import 'fake_backend.dart';
import 'test_helpers.dart';

const String taPath = '${experiencePath}ta/';

Future<void> fillExperienceForm(
  WidgetTester tester, {
  String title = 'Teaching Assistant',
}) async {
  await tester.enterText(fieldLabelled('Title'), title);
  await tester.enterText(fieldLabelled('Description'), 'Graded weekly labs.');
  await tester.enterText(
    fieldLabelled('Thumbnail URL'),
    'https://example.com/ta.png',
  );
  await pickDay15(tester, 'End Date');
}

Future<void> openExperienceDetail(WidgetTester tester) async {
  await tapText(tester, 'View Experience');
  await tapText(tester, 'PBP Teaching Assistant');
}

void main() {
  testWidgets('View Experience lists the entries without a login', (
    tester,
  ) async {
    final FakeBackend backend = FakeBackend();
    await pumpApp(tester, backend);

    await tapText(tester, 'View Experience');

    expect(find.byType(ExperienceListPage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
    expect(find.text('PBP Teaching Assistant'), findsOneWidget);
    expect(find.text('Part-Time'), findsOneWidget);
    expect(find.text('Ongoing'), findsOneWidget);
    final http.Request request = backend.requests.single;
    expect(request.url.path, experiencePath);
    expect(request.headers.containsKey('Authorization'), isFalse);
  });

  testWidgets('the drawer opens the experience list', (tester) async {
    await pumpApp(tester, FakeBackend());

    await openDrawer(tester);
    await tapDrawerItem(tester, 'View Experience');

    expect(find.byType(ExperienceListPage), findsOneWidget);
    expect(find.text('PBP Teaching Assistant'), findsOneWidget);
  });

  testWidgets('an empty experience list says so', (tester) async {
    final FakeBackend backend = FakeBackend();
    backend.experiences.clear();
    await pumpApp(tester, backend);

    await tapText(tester, 'View Experience');

    expect(find.text('No experience entries yet.'), findsOneWidget);
  });

  testWidgets('a failed experience load offers Retry', (tester) async {
    final FakeBackend backend = FakeBackend()..listStatus = 500;
    await pumpApp(tester, backend);

    await tapText(tester, 'View Experience');

    expect(find.text("Couldn't load the experience entries."), findsOneWidget);
    expect(find.text('The server had a problem.'), findsOneWidget);

    backend.listStatus = 200;
    await tapText(tester, 'Retry');

    expect(find.text('PBP Teaching Assistant'), findsOneWidget);
  });

  testWidgets('a finished experience shows every field on its page', (
    tester,
  ) async {
    final FakeBackend backend = FakeBackend();
    backend.experiences[0] = experienceJson(
      thumbnail: 'https://example.com/ta.png',
      endedAt: '2025-06-30T00:00:00Z',
    );
    await pumpApp(tester, backend);
    await tapText(tester, 'View Experience');

    expect(find.text('Ended Jun 30, 2025'), findsOneWidget);

    await tapText(tester, 'PBP Teaching Assistant');

    expect(find.byType(ExperienceDetailPage), findsOneWidget);
    expect(find.text('Part-Time'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Ongoing'), findsNothing);
    expect(find.text('Nov 20, 2026'), findsOneWidget);
    expect(find.text('Jun 30, 2025'), findsOneWidget);
    expect(find.text('https://example.com/ta.png'), findsOneWidget);
    expect(
      find.text('Help students understand web development.'),
      findsOneWidget,
    );
  });

  testWidgets('an ongoing experience has no end date on its page', (
    tester,
  ) async {
    await pumpApp(tester, FakeBackend());

    await openExperienceDetail(tester);

    expect(find.text('Ongoing'), findsOneWidget);
    expect(find.text('End date'), findsNothing);
    expect(find.text('None'), findsOneWidget);
  });

  testWidgets('Add Experience asks you to log in first', (tester) async {
    await pumpApp(tester, FakeBackend());

    await tapText(tester, 'Add Experience');

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(ExperienceFormPage), findsNothing);

    await logIn(tester);

    expect(find.byType(ExperienceFormPage), findsOneWidget);
  });

  testWidgets('the drawer opens the experience form above the home screen', (
    tester,
  ) async {
    await pumpApp(tester, FakeBackend());

    await openDrawer(tester);
    await tapDrawerItem(tester, 'Add Experience');

    expect(find.byType(LoginPage), findsOneWidget);

    await logIn(tester);

    expect(find.byType(ExperienceFormPage), findsOneWidget);

    await goBack(tester);

    expect(find.byType(ExperienceFormPage), findsNothing);
    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets('Home in the drawer takes a form back to the home screen', (
    tester,
  ) async {
    await pumpApp(tester, FakeBackend());
    await openFormAndLogIn(tester, 'Add Experience');

    await openDrawer(tester);
    await tapDrawerItem(tester, 'Home');

    expect(find.byType(ExperienceFormPage), findsNothing);
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(rootNavigator(tester).canPop(), isFalse);
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

  testWidgets('saving a valid experience posts it with your token', (
    tester,
  ) async {
    usePhoneScreen(tester);
    final FakeBackend backend = FakeBackend();
    await pumpApp(tester, backend);
    await openFormAndLogIn(tester, 'Add Experience');

    await fillExperienceForm(tester);
    await tapSave(tester);

    final http.Request post = backend.requestsTo('POST', experiencePath).single;
    expect(post.headers['Authorization'], 'Token token-1');
    final Map<String, dynamic> body = jsonBody(post);
    expect(body.keys.toSet(), {
      'title',
      'category',
      'description',
      'thumbnail',
      'ended_at',
    });
    expect(body['category'], 'full-time');
    expect(body['thumbnail'], 'https://example.com/ta.png');
    expect(body['ended_at'], matches(RegExp(r'^\d{4}-\d{2}-15T00:00:00$')));

    expect(find.text('Experience added successfully!'), findsOneWidget);
    expect(find.text('Title: Teaching Assistant'), findsOneWidget);
    expect(find.text('Category: Full-Time'), findsOneWidget);
    expect(find.text('Description: Graded weekly labs.'), findsOneWidget);
    expect(find.text('Thumbnail: https://example.com/ta.png'), findsOneWidget);
    expect(
      find.textContaining(RegExp(r'^End date: \w{3} 15, \d{4}$')),
      findsOneWidget,
    );

    await tapText(tester, 'OK');

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(ExperienceFormPage), findsOneWidget);
    expect(find.text('Teaching Assistant'), findsNothing);
  });

  testWidgets('an expired token asks you to log in again before saving', (
    tester,
  ) async {
    usePhoneScreen(tester);
    final FakeBackend backend = FakeBackend();
    await pumpApp(tester, backend);
    await openFormAndLogIn(tester, 'Add Experience');
    await fillExperienceForm(tester);
    backend.expireTokens();

    await tapSave(tester);

    expect(find.byType(LoginPage), findsOneWidget);

    await logIn(tester);

    expect(find.text('Experience added successfully!'), findsOneWidget);
    final List<http.Request> posts = backend.requestsTo('POST', experiencePath);
    expect(posts, hasLength(2));
    expect(posts.first.headers['Authorization'], 'Token token-1');
    expect(posts.last.headers['Authorization'], 'Token token-2');
  });

  testWidgets('a rejected experience shows why and keeps your input', (
    tester,
  ) async {
    usePhoneScreen(tester);
    await pumpApp(tester, FakeBackend());
    await openFormAndLogIn(tester, 'Add Experience');
    await fillExperienceForm(tester, title: '<b></b>');

    await tapSave(tester);

    expect(
      find.text(
        "Couldn't save (400): Title: This field can't contain only HTML tags.",
      ),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('<b></b>'), findsOneWidget);
  });

  testWidgets('Add on the experience list returns to a refreshed list', (
    tester,
  ) async {
    usePhoneScreen(tester);
    final FakeBackend backend = FakeBackend();
    await pumpApp(tester, backend);
    await tapText(tester, 'View Experience');

    await tapText(tester, 'Add');

    expect(find.byType(LoginPage), findsOneWidget);

    await logIn(tester);
    await fillExperienceForm(tester);
    await tapSave(tester);
    await tapText(tester, 'OK');
    await goBack(tester);

    expect(find.byType(ExperienceListPage), findsOneWidget);
    expect(find.text('Teaching Assistant'), findsOneWidget);
    expect(backend.requestsTo('GET', experiencePath), hasLength(2));
  });

  testWidgets('deleting an experience asks first, then removes it', (
    tester,
  ) async {
    final FakeBackend backend = FakeBackend();
    await pumpApp(tester, backend);
    await logInFromDrawer(tester);
    await openExperienceDetail(tester);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete this experience?'), findsOneWidget);

    await tapText(tester, 'Delete');

    final http.Request delete = backend.requestsTo('DELETE', taPath).single;
    expect(delete.headers['Authorization'], 'Token token-1');
    expect(find.byType(ExperienceDetailPage), findsNothing);
    expect(find.text('Experience deleted.'), findsOneWidget);
    expect(find.text('No experience entries yet.'), findsOneWidget);
  });

  testWidgets('deleting while logged out asks you to log in first', (
    tester,
  ) async {
    final FakeBackend backend = FakeBackend();
    await pumpApp(tester, backend);
    await openExperienceDetail(tester);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Delete');

    expect(find.byType(LoginPage), findsOneWidget);
    expect(backend.requestsTo('DELETE', taPath), isEmpty);

    await logIn(tester);

    expect(backend.experiences, isEmpty);
    expect(find.text('No experience entries yet.'), findsOneWidget);
  });

  testWidgets('cancelling the delete keeps the experience', (tester) async {
    final FakeBackend backend = FakeBackend();
    await pumpApp(tester, backend);
    await openExperienceDetail(tester);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Cancel');

    expect(find.byType(ExperienceDetailPage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
    expect(backend.experiences, hasLength(1));
  });

  testWidgets('a refused delete explains why', (tester) async {
    final FakeBackend backend = FakeBackend()..canWrite = false;
    await pumpApp(tester, backend);
    await logInFromDrawer(tester);
    await openExperienceDetail(tester);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Delete');

    expect(
      find.text("Couldn't delete (403): Your role can't perform this action."),
      findsOneWidget,
    );
    expect(find.byType(ExperienceDetailPage), findsOneWidget);
    expect(backend.experiences, hasLength(1));
  });

  testWidgets('going back with unsaved input asks before discarding it', (
    tester,
  ) async {
    await pumpApp(tester, FakeBackend());
    await openFormAndLogIn(tester, 'Add Experience');

    await tester.enterText(fieldLabelled('Title'), 'Draft');
    await tester.pump();
    await goBack(tester);

    expect(find.text('Discard this entry?'), findsOneWidget);

    await tapText(tester, 'Discard');

    expect(find.byType(ExperienceFormPage), findsNothing);
    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets('leaving through the drawer with unsaved input asks first', (
    tester,
  ) async {
    await pumpApp(tester, FakeBackend());
    await openFormAndLogIn(tester, 'Add Experience');

    await tester.enterText(fieldLabelled('Title'), 'Draft');
    await tester.pump();
    await openDrawer(tester);
    await tapDrawerItem(tester, 'Home');

    expect(find.text('Discard this entry?'), findsOneWidget);

    await tapText(tester, 'Keep editing');

    expect(find.byType(ExperienceFormPage), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
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
}
