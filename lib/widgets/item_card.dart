import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/auth_guard.dart';
import 'package:provider/provider.dart';

class ItemCard extends StatelessWidget {
  static const BorderRadius _borderRadius = BorderRadius.all(
    Radius.circular(12),
  );

  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(item.icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: item.color,
          behavior: SnackBarBehavior.floating,
          showCloseIcon: true,
          closeIconColor: Colors.white,
        ),
      );
  }

  Future<void> _handleTap(BuildContext context) async {
    if (item.logsOut) {
      await _logOut(context);
      return;
    }
    _showMessage(context, 'You pressed the ${item.name} button!');
    final WidgetBuilder? destination = item.destination;
    if (destination == null) {
      return;
    }
    if (item.requiresLogin && !await ensureLoggedIn(context)) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: destination));
  }

  Future<void> _logOut(BuildContext context) async {
    final AuthState auth = context.read<AuthState>();
    if (!auth.isLoggedIn) {
      _showMessage(context, "You aren't logged in.");
      return;
    }
    await auth.logout();
    if (context.mounted) {
      _showMessage(context, "You've been logged out.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: item.tooltip,
      child: Material(
        color: item.color,
        borderRadius: _borderRadius,
        child: InkWell(
          borderRadius: _borderRadius,
          onTap: () => _handleTap(context),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: LayoutBuilder(
              builder: (_, constraints) => FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, color: Colors.white, size: 30.0),
                      const SizedBox(height: 6),
                      Text(
                        item.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
