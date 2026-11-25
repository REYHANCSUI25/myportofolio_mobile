import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/education.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  factory ApiException.fromResponse(http.Response response) {
    return ApiException(response.statusCode, _readableError(response));
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  final http.Client _client;
  final String baseUrl;

  ApiClient(this._client, {this.baseUrl = apiBaseUrl});

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<List<Education>> getEducationList() async {
    final http.Response response = await _client.get(
      _uri('/api/v1/education/'),
      headers: const {'Accept': 'application/json'},
    );
    _ensureSuccess(response);

    final List<dynamic> entries = _decode(response) as List<dynamic>;
    return [
      for (final entry in entries)
        Education.fromJson(entry as Map<String, dynamic>),
    ];
  }

  Future<Education> createEducation(
    Education education, {
    required String token,
  }) async {
    final http.Response response = await _client.post(
      _uri('/api/v1/education/'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(education.toJson()),
    );
    _ensureSuccess(response);

    return Education.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<String> obtainToken(String username, String password) async {
    final http.Response response = await _client.post(
      _uri('/api/v1/auth/token/'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'username': username, 'password': password}),
    );
    _ensureSuccess(response);

    final Map<String, dynamic> data = _decode(response) as Map<String, dynamic>;
    return data['token'] as String;
  }

  Future<void> logout({required String token}) async {
    final http.Response response = await _client.post(
      _uri('/api/v1/auth/logout/'),
      headers: {'Accept': 'application/json', 'Authorization': 'Token $token'},
    );
    _ensureSuccess(response);
  }

  static Object? _decode(http.Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  static void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw ApiException.fromResponse(response);
  }
}

String describeError(Object error) {
  if (error is ApiException) {
    return error.message;
  }
  if (error is http.ClientException) {
    return "Couldn't reach the server. Check that Django is running.";
  }
  return "Couldn't read the server's response.";
}

Object? _tryDecode(http.Response response) {
  try {
    return jsonDecode(utf8.decode(response.bodyBytes));
  } on FormatException {
    return null;
  }
}

String _readableError(http.Response response) {
  final String fallback = 'Request failed (HTTP ${response.statusCode}).';
  final Object? data = _tryDecode(response);
  if (data is! Map<String, dynamic>) {
    return fallback;
  }

  final Object? detail = data['detail'];
  if (detail is String) {
    return detail;
  }

  final List<String> messages = [];
  for (final MapEntry<String, dynamic> entry in data.entries) {
    final String prefix = entry.key == 'non_field_errors'
        ? ''
        : '${_humanize(entry.key)}: ';
    final Object? errors = entry.value;
    for (final Object? error in errors is List ? errors : [errors]) {
      if (error is String) {
        messages.add('$prefix$error');
      }
    }
  }
  return messages.isEmpty ? fallback : messages.join(' ');
}

String _humanize(String field) {
  final String words = field.replaceAll('_', ' ');
  if (words.isEmpty) {
    return words;
  }
  return words[0].toUpperCase() + words.substring(1);
}
