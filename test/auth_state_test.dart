import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

import 'fake_backend.dart';

void main() {
  test('starts logged out', () {
    final AuthState auth = AuthState(FakeBackend().client);

    expect(auth.isLoggedIn, isFalse);
    expect(auth.token, isNull);
    expect(auth.username, isNull);
  });

  test('login keeps the token and the username and notifies', () async {
    final AuthState auth = AuthState(FakeBackend().client);
    int notifications = 0;
    auth.addListener(() => notifications++);

    await auth.login('owner', 'test-password');

    expect(auth.isLoggedIn, isTrue);
    expect(auth.token, 'token-1');
    expect(auth.username, 'owner');
    expect(notifications, 1);
  });

  test('a rejected login leaves you logged out', () async {
    final AuthState auth = AuthState(FakeBackend().client);

    await expectLater(
      auth.login('owner', 'wrong-password'),
      throwsA(isA<ApiException>()),
    );

    expect(auth.isLoggedIn, isFalse);
    expect(auth.username, isNull);
  });

  test('logout revokes the token on the server and forgets it', () async {
    final FakeBackend backend = FakeBackend();
    final AuthState auth = AuthState(backend.client);
    await auth.login('owner', 'test-password');
    int notifications = 0;
    auth.addListener(() => notifications++);

    await auth.logout();

    expect(auth.isLoggedIn, isFalse);
    expect(auth.username, isNull);
    expect(notifications, 1);
    final http.Request logout = backend.requestsTo('POST', logoutPath).single;
    expect(logout.headers['Authorization'], 'Token token-1');
  });

  test('logout forgets the token even if the server rejects it', () async {
    final FakeBackend backend = FakeBackend();
    final AuthState auth = AuthState(backend.client);
    await auth.login('owner', 'test-password');
    backend.expireTokens();

    await auth.logout();

    expect(auth.isLoggedIn, isFalse);
  });

  test('logout forgets the token even if the server is down', () async {
    final FakeBackend backend = FakeBackend();
    final AuthState auth = AuthState(backend.client);
    await auth.login('owner', 'test-password');
    backend.offline = true;

    await auth.logout();

    expect(auth.isLoggedIn, isFalse);
  });

  test('logout does nothing when you are not logged in', () async {
    final FakeBackend backend = FakeBackend();
    final AuthState auth = AuthState(backend.client);

    await auth.logout();

    expect(backend.requests, isEmpty);
  });
}
