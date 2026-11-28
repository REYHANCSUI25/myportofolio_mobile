import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/models/experience.dart';

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
  static const String _educationPath = '/api/v1/education/';
  static const String _experiencePath = '/api/v1/experience/';

  final http.Client _client;
  final String baseUrl;

  ApiClient(this._client, {this.baseUrl = apiBaseUrl});

  Future<List<Education>> getEducationList() async {
    final List<dynamic> entries = await _getList(_educationPath);
    return [
      for (final entry in entries)
        Education.fromJson(entry as Map<String, dynamic>),
    ];
  }

  Future<Education> createEducation(
    Education education, {
    required String token,
  }) async {
    final Map<String, dynamic> saved = await _create(
      _educationPath,
      education.toJson(),
      token,
    );
    return Education.fromJson(saved);
  }

  Future<List<Experience>> getExperienceList() async {
    final List<dynamic> entries = await _getList(_experiencePath);
    return [
      for (final entry in entries)
        Experience.fromJson(entry as Map<String, dynamic>),
    ];
  }

  Future<Experience> createExperience(
    Experience experience, {
    required String token,
  }) async {
    final Map<String, dynamic> saved = await _create(
      _experiencePath,
      experience.toJson(),
      token,
    );
    return Experience.fromJson(saved);
  }

  Future<void> deleteExperience(String id, {required String token}) async {
    final http.Response response = await _client.delete(
      _uri('$_experiencePath$id/'),
      headers: _headers(token),
    );
    _ensureSuccess(response);
  }

  Future<String> obtainToken(String username, String password) async {
    final http.Response response = await _client.post(
      _uri('/api/v1/auth/token/'),
      headers: _jsonHeaders(),
      body: jsonEncode({'username': username, 'password': password}),
    );
    _ensureSuccess(response);

    final Map<String, dynamic> data = _decode(response) as Map<String, dynamic>;
    return data['token'] as String;
  }

  Future<void> logout({required String token}) async {
    final http.Response response = await _client.post(
      _uri('/api/v1/auth/logout/'),
      headers: _headers(token),
    );
    _ensureSuccess(response);
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<List<dynamic>> _getList(String path) async {
    final http.Response response = await _client.get(
      _uri(path),
      headers: _headers(),
    );
    _ensureSuccess(response);
    return _decode(response) as List<dynamic>;
  }

  Future<Map<String, dynamic>> _create(
    String path,
    Map<String, dynamic> body,
    String token,
  ) async {
    final http.Response response = await _client.post(
      _uri(path),
      headers: _jsonHeaders(token),
      body: jsonEncode(body),
    );
    _ensureSuccess(response);
    return _decode(response) as Map<String, dynamic>;
  }

  static Map<String, String> _headers([String? token]) {
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };
  }

  static Map<String, String> _jsonHeaders([String? token]) {
    return {
      ..._headers(token),
      'Content-Type': 'application/json; charset=UTF-8',
    };
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
