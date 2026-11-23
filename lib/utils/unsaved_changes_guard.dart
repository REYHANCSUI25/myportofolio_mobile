import 'package:material_ui/material_ui.dart';

mixin UnsavedChangesGuard<T extends StatefulWidget> on State<T> {
  bool _hasUnsavedInput = false;

  bool get hasUnsavedInput => _hasUnsavedInput;

  bool get _isDrawerOpen {
    return ModalRoute.of(context)?.willHandlePopInternally ?? false;
  }

  void markUnsaved() {
    if (!_hasUnsavedInput) {
      setState(() => _hasUnsavedInput = true);
    }
  }

  void markSaved() {
    setState(() => _hasUnsavedInput = false);
  }

  Future<bool> confirmLeave() async {
    if (!_hasUnsavedInput) {
      return true;
    }
    final bool? discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard this entry?'),
        content: const Text(
          "What you've typed hasn't been saved and will be lost.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> handlePop(bool didPop, Object? result) async {
    if (didPop) {
      return;
    }
    if (_isDrawerOpen) {
      Navigator.pop(context, result);
      return;
    }
    final bool leave = await confirmLeave();
    if (leave && mounted) {
      Navigator.pop(context, result);
    }
  }
}
