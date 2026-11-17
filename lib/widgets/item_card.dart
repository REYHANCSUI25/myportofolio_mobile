import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';

class ItemCard extends StatelessWidget {
  static const BorderRadius _borderRadius = BorderRadius.all(
    Radius.circular(12),
  );

  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  void _showPressedMessage(BuildContext context) {
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
                  'You pressed the ${item.name} button!',
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

  void _openDestination(BuildContext context) {
    final WidgetBuilder? destination = item.destination;
    if (destination != null) {
      Navigator.push(context, MaterialPageRoute(builder: destination));
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
          onTap: () {
            _showPressedMessage(context);
            _openDestination(context);
          },
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
