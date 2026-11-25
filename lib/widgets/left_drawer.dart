import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/education_list.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/auth_guard.dart';
import 'package:provider/provider.dart';

enum DrawerPage { home, viewEducation, addEducation, addExperience }

class LeftDrawer extends StatelessWidget {
  final DrawerPage? currentPage;
  final Future<bool> Function()? confirmLeave;

  const LeftDrawer({super.key, this.currentPage, this.confirmLeave});

  Future<void> _open(BuildContext context, DrawerPage page) async {
    final NavigatorState navigator = Navigator.of(context);
    final AuthState auth = context.read<AuthState>();
    navigator.pop();
    if (page == currentPage) {
      return;
    }
    final Future<bool> Function()? canLeave = confirmLeave;
    if (canLeave != null && !await canLeave()) {
      return;
    }
    final bool needsLogin = page == DrawerPage.addEducation;
    if (needsLogin && !await loginIfNeeded(navigator, auth)) {
      return;
    }
    if (!navigator.mounted) {
      return;
    }
    switch (page) {
      case DrawerPage.home:
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MyHomePage()),
          (route) => false,
        );
      case DrawerPage.viewEducation:
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const EducationListPage()),
          (route) => route.isFirst,
        );
      case DrawerPage.addEducation:
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const EducationFormPage()),
          (route) => route.isFirst,
        );
      case DrawerPage.addExperience:
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ExperienceFormPage()),
          (route) => route.isFirst,
        );
    }
  }

  Future<void> _logIn(BuildContext context) async {
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AuthState auth = context.read<AuthState>();
    navigator.pop();
    if (await loginIfNeeded(navigator, auth)) {
      _showMessage(messenger, 'Logged in as ${auth.username}.');
    }
  }

  Future<void> _logOut(BuildContext context) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AuthState auth = context.read<AuthState>();
    Navigator.pop(context);
    await auth.logout();
    _showMessage(messenger, "You've been logged out.");
  }

  static void _showMessage(ScaffoldMessengerState messenger, String message) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _pageTile(
    BuildContext context,
    DrawerPage page,
    IconData icon,
    String title,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: page == currentPage,
      onTap: () => _open(context, page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AuthState auth = context.watch<AuthState>();

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Portfolio',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Explore my education and experiences!',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, color: colorScheme.onPrimary),
                ),
              ],
            ),
          ),
          _pageTile(context, DrawerPage.home, Icons.home_outlined, 'Home'),
          _pageTile(
            context,
            DrawerPage.viewEducation,
            Icons.school_outlined,
            'View Education',
          ),
          _pageTile(
            context,
            DrawerPage.addEducation,
            Icons.add_circle_outline,
            'Add Education',
          ),
          _pageTile(
            context,
            DrawerPage.addExperience,
            Icons.work_outline,
            'Add Experience',
          ),
          const Divider(),
          if (auth.isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              subtitle: Text('Logged in as ${auth.username}'),
              onTap: () => _logOut(context),
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () => _logIn(context),
            ),
        ],
      ),
    );
  }
}
