import 'package:material_ui/material_ui.dart';

class EmptyListMessage extends StatelessWidget {
  final String message;

  const EmptyListMessage(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: Text(message)),
        ),
      ),
    );
  }
}
