import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login.dart';
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
