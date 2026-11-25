import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

import 'fake_backend.dart';

ApiClient clientReturning(int statusCode, String body) {
  return ApiClient(
    MockClient((request) async => http.Response(body, statusCode)),
    baseUrl: 'http://test',
  );
}

Matcher throwsApiError(int statusCode, String message) {
  return throwsA(
    isA<ApiException>()
        .having((error) => error.statusCode, 'statusCode', statusCode)
        .having((error) => error.message, 'message', message),
  );
}

void main() {
  test('getEducationList asks for JSON and reads every entry', () async {
    final FakeBackend backend = FakeBackend();

    final List<Education> entries = await backend.client.getEducationList();

    final http.Request request = backend.requests.single;
    expect(request.method, 'GET');
    expect(request.url.toString(), 'http://test/api/v1/education/');
    expect(request.headers['Accept'], 'application/json');
    expect(entries, hasLength(1));
    expect(entries.single.institution, 'Universitas Indonesia');
    expect(entries.single.startedAt, DateTime(2025, 8, 1));
  });

  test('createEducation posts the writable fields with the token', () async {
    final FakeBackend backend = FakeBackend();
    final ApiClient api = backend.client;
    final String token = backend.issueToken();
    final Education entry = Education(
      institution: 'Test University',
      degree: 'Bachelor of Testing',
      description: 'Wrote widget tests.',
      startedAt: DateTime(2026, 2, 1),
    );

    final Education saved = await api.createEducation(entry, token: token);

    final http.Request request = backend.requests.single;
    expect(request.method, 'POST');
    expect(request.url.path, educationPath);
    expect(request.headers['Authorization'], 'Token $token');
    expect(request.headers['Content-Type'], 'application/json; charset=UTF-8');
    expect(jsonBody(request), {
      'institution': 'Test University',
      'degree': 'Bachelor of Testing',
      'description': 'Wrote widget tests.',
      'started_at': '2026-02-01',
      'ended_at': null,
    });
    expect(saved.id, 'created-1');
    expect(saved.institution, 'Test University');
    expect(saved.starCount, 0);
  });

  test('obtainToken sends the credentials and returns the token', () async {
    final FakeBackend backend = FakeBackend();
    final ApiClient api = backend.client;

    final String token = await api.obtainToken('owner', 'test-password');

    expect(token, 'token-1');
    expect(backend.requests.single.url.path, tokenPath);
    expect(jsonBody(backend.requests.single), {
      'username': 'owner',
      'password': 'test-password',
    });
  });

  test('logout posts the token to the logout endpoint', () async {
    final FakeBackend backend = FakeBackend();
    final String token = backend.issueToken();

    await backend.client.logout(token: token);

    final http.Request request = backend.requests.single;
    expect(request.method, 'POST');
    expect(request.url.path, logoutPath);
    expect(request.headers['Authorization'], 'Token $token');
  });

  group('error messages', () {
    test('a rejected login gives the reason from the server', () async {
      final ApiClient api = FakeBackend().client;

      await expectLater(
        api.obtainToken('owner', 'wrong-password'),
        throwsApiError(400, 'Unable to log in with provided credentials.'),
      );
    });

    test('a detail message is passed on as it is', () async {
      const String body = '{"detail": "Invalid token."}';
      final ApiClient api = clientReturning(401, body);

      await expectLater(
        api.getEducationList(),
        throwsApiError(401, 'Invalid token.'),
      );
    });

    test('field errors start with the name of the field', () async {
      final ApiClient api = clientReturning(
        400,
        '{"started_at": ["Invalid date."], "degree": ["Required."]}',
      );

      await expectLater(
        api.getEducationList(),
        throwsApiError(400, 'Started at: Invalid date. Degree: Required.'),
      );
    });

    test('an HTML error page falls back to the status code', () async {
      final ApiClient api = clientReturning(500, '<h1>Server Error</h1>');

      await expectLater(
        api.getEducationList(),
        throwsApiError(500, 'Request failed (HTTP 500).'),
      );
    });

    test('describeError gives a readable message for each failure', () {
      expect(
        describeError(const ApiException(404, 'Not found.')),
        'Not found.',
      );
      expect(
        describeError(http.ClientException('Connection refused')),
        "Couldn't reach the server. Check that Django is running.",
      );
      expect(
        describeError(const FormatException('Unexpected character')),
        "Couldn't read the server's response.",
      );
    });
  });
}
