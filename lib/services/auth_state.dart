import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/services/api_client.dart';

class AuthState extends ChangeNotifier {
  final ApiClient _apiClient;
  String? _token;
  String? _username;

  AuthState(this._apiClient);

  String? get token => _token;
  String? get username => _username;
  bool get isLoggedIn => _token != null;

  Future<void> login(String username, String password) async {
    _token = await _apiClient.obtainToken(username, password);
    _username = username;
    notifyListeners();
  }

  Future<void> logout() async {
    final String? current = _token;
    if (current == null) {
      return;
    }
    try {
      await _apiClient.logout(token: current);
    } on ApiException catch (_) {
    } on http.ClientException catch (_) {
    } finally {
      _token = null;
      _username = null;
      notifyListeners();
    }
  }
}
