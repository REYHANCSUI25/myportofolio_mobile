import 'package:material_ui/material_ui.dart';

class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;
  final String tooltip;
  final WidgetBuilder? destination;

  const ItemHomepage({
    required this.name,
    required this.icon,
    required this.color,
    required this.tooltip,
    this.destination,
  });
}
