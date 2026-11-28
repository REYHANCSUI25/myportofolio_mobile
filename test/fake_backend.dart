import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

const String educationPath = '/api/v1/education/';
const String experiencePath = '/api/v1/experience/';
const String tokenPath = '/api/v1/auth/token/';
const String logoutPath = '/api/v1/auth/logout/';

Map<String, Object?> educationJson({
  String id = 'ui',
  String institution = 'Universitas Indonesia',
  String degree = 'S1 Ilmu Komputer KKI',
  String description = 'Studying computer science.',
  String startedAt = '2025-08-01',
  String? endedAt,
  int starCount = 1,
}) {
  return {
    'id': id,
    'institution': institution,
    'degree': degree,
    'description': description,
    'started_at': startedAt,
    'ended_at': endedAt,
    'is_ongoing': endedAt == null,
    'star_count': starCount,
    'is_starred': false,
  };
}

Map<String, Object?> experienceJson({
  String id = 'ta',
  String title = 'PBP Teaching Assistant',
  String category = 'part-time',
  String description = 'Help students understand web development.',
  String? thumbnail,
  String startedAt = '2026-11-20T12:00:00Z',
  String? endedAt,
}) {
  return {
    'id': id,
    'title': title,
    'category': category,
    'description': description,
    'thumbnail': thumbnail,
    'started_at': startedAt,
    'ended_at': endedAt,
    'is_ongoing': endedAt == null,
  };
}

Map<String, dynamic> jsonBody(http.Request request) {
  return jsonDecode(request.body) as Map<String, dynamic>;
}

class FakeBackend {
  static const String username = 'owner';
  static const String password = 'test-password';

  final List<Map<String, Object?>> entries = [educationJson()];
  final List<Map<String, Object?>> experiences = [experienceJson()];
  final List<http.Request> requests = [];
  final Set<String> _validTokens = {};
  int _issuedTokens = 0;
  int listStatus = 200;
  bool offline = false;
  bool canWrite = true;

  late final ApiClient client = ApiClient(
    MockClient(_handle),
    baseUrl: 'http://test',
  );

  String issueToken() {
    _issuedTokens += 1;
    final String token = 'token-$_issuedTokens';
    _validTokens.add(token);
    return token;
  }

  void expireTokens() => _validTokens.clear();

  List<http.Request> requestsTo(String method, String path) {
    return [
      for (final request in requests)
        if (request.method == method && request.url.path == path) request,
    ];
  }

  Future<http.Response> _handle(http.Request request) async {
    requests.add(request);
    if (offline) {
      throw http.ClientException('Connection refused', request.url);
    }
    final String method = request.method;
    final String path = request.url.path;

    if (method == 'GET' && (path == educationPath || path == experiencePath)) {
      if (listStatus != 200) {
        return _json({'detail': 'The server had a problem.'}, listStatus);
      }
      return _json(path == educationPath ? entries : experiences, 200);
    }

    if (method == 'POST' && path == tokenPath) {
      final Map<String, dynamic> body = jsonBody(request);
      if (body['username'] != username || body['password'] != password) {
        return _json({
          'non_field_errors': ['Unable to log in with provided credentials.'],
        }, 400);
      }
      return _json({'token': issueToken()}, 200);
    }

    final String header = request.headers['Authorization'] ?? '';
    final String token = header.replaceFirst('Token ', '');
    if (!_validTokens.contains(token)) {
      return _json({'detail': 'Invalid token.'}, 401);
    }

    if (method == 'POST' && path == logoutPath) {
      _validTokens.remove(token);
      return http.Response('', 204);
    }

    if (!canWrite) {
      return _json({'detail': "Your role can't perform this action."}, 403);
    }

    if (method == 'POST' && path == experiencePath) {
      return _createExperience(jsonBody(request));
    }

    if (method == 'DELETE' && path.startsWith(experiencePath)) {
      final String id = path.substring(experiencePath.length).split('/').first;
      final int before = experiences.length;
      experiences.removeWhere((entry) => entry['id'] == id);
      if (experiences.length == before) {
        return _json({'detail': 'No Experience matches the given query.'}, 404);
      }
      return http.Response('', 204);
    }

    if (method == 'POST' && path == educationPath) {
      final Map<String, dynamic> body = jsonBody(request);
      final Map<String, Object?> saved = educationJson(
        id: 'created-${entries.length}',
        institution: body['institution'] as String,
        degree: body['degree'] as String,
        description: body['description'] as String,
        startedAt: body['started_at'] as String,
        endedAt: body['ended_at'] as String?,
        starCount: 0,
      );
      entries.insert(0, saved);
      return _json(saved, 201);
    }

    return _json({'detail': 'Not found.'}, 404);
  }

  http.Response _createExperience(Map<String, dynamic> body) {
    final String title = body['title'] as String;
    if (title == '<b></b>') {
      return _json({
        'title': ["This field can't contain only HTML tags."],
      }, 400);
    }
    final String? endedAt = body['ended_at'] as String?;
    final Map<String, Object?> saved = experienceJson(
      id: 'created-experience-${experiences.length}',
      title: title,
      category: body['category'] as String,
      description: body['description'] as String,
      thumbnail: body['thumbnail'] as String?,
      startedAt: '2026-11-27T12:00:00Z',
      endedAt: endedAt == null ? null : '${endedAt}Z',
    );
    experiences.insert(0, saved);
    return _json(saved, 201);
  }

  static http.Response _json(Object body, int status) {
    return http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );
  }
}
