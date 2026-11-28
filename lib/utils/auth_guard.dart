import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

Future<bool> ensureLoggedIn(BuildContext context) {
  return loginIfNeeded(Navigator.of(context), context.read<AuthState>());
}

Future<bool> loginIfNeeded(NavigatorState navigator, AuthState auth) async {
  if (auth.isLoggedIn) {
    return true;
  }
  final bool? loggedIn = await navigator.push<bool>(
    MaterialPageRoute(builder: (context) => const LoginPage()),
  );
  return loggedIn ?? false;
}

Future<T?> requestWithLogin<T>(
  NavigatorState navigator,
  AuthState auth,
  Future<T> Function(String token) request,
) async {
  if (!await loginIfNeeded(navigator, auth)) {
    return null;
  }
  try {
    return await request(auth.token!);
  } on ApiException catch (error) {
    if (error.statusCode != 401) {
      rethrow;
    }
  }
  await auth.logout();
  if (!await loginIfNeeded(navigator, auth)) {
    return null;
  }
  return request(auth.token!);
}
