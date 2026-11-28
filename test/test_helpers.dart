import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/widgets/date_form_field.dart';

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

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

Future<void> tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.pumpAndSettle();
  await tapText(tester, 'Save');
}

Future<void> pickDay15(WidgetTester tester, String label) async {
  final Finder field = find.widgetWithText(DateFormField, label);
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tapText(tester, '15');
  await tapText(tester, 'OK');
}

Finder fieldLabelled(String label) {
  return find.widgetWithText(TextFormField, label);
}

NavigatorState rootNavigator(WidgetTester tester) {
  return tester.state<NavigatorState>(find.byType(Navigator));
}

Future<void> goBack(WidgetTester tester) async {
  rootNavigator(tester).maybePop();
  await tester.pumpAndSettle();
}

Future<void> logIn(
  WidgetTester tester, {
  String password = FakeBackend.password,
}) async {
  await tester.enterText(fieldLabelled('Username'), FakeBackend.username);
  await tester.enterText(fieldLabelled('Password'), password);
  await tapText(tester, 'Log in');
}

Future<void> logInFromDrawer(WidgetTester tester) async {
  await openDrawer(tester);
  await tapDrawerItem(tester, 'Login');
  await logIn(tester);
}

Future<void> openFormAndLogIn(WidgetTester tester, String button) async {
  await tapText(tester, button);
  await logIn(tester);
}
