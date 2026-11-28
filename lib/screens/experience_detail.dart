import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/auth_guard.dart';
import 'package:myportofolio_mobile/utils/snack_bars.dart';
import 'package:myportofolio_mobile/widgets/detail_row.dart';
import 'package:provider/provider.dart';

class ExperienceDetailPage extends StatefulWidget {
  final Experience entry;

  const ExperienceDetailPage({super.key, required this.entry});

  @override
  State<ExperienceDetailPage> createState() => _ExperienceDetailPageState();
}

class _ExperienceDetailPageState extends State<ExperienceDetailPage> {
  bool _isDeleting = false;

  Future<bool> _confirmDelete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete this experience?'),
          content: Text(
            '"${widget.entry.title}" will be removed from your portfolio.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  Future<void> _delete() async {
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final ApiClient api = context.read<ApiClient>();
    final AuthState auth = context.read<AuthState>();
    final String id = widget.entry.id!;
    if (_isDeleting || !await _confirmDelete() || !mounted) {
      return;
    }

    setState(() => _isDeleting = true);
    bool? deleted;
    try {
      deleted = await requestWithLogin(navigator, auth, (token) async {
        await api.deleteExperience(id, token: token);
        return true;
      });
    } on ApiException catch (error) {
      showSnackBarMessage(
        messenger,
        "Couldn't delete (${error.statusCode}): ${error.message}",
      );
    } on http.ClientException catch (error) {
      showSnackBarMessage(messenger, describeError(error));
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
    if (deleted == true) {
      showSnackBarMessage(messenger, 'Experience deleted.');
      if (mounted) {
        navigator.pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Experience entry = widget.entry;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final DateTime? startedAt = entry.startedAt;
    final DateTime? endedAt = entry.endedAt;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Experience Details'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: _isDeleting ? null : _delete,
            tooltip: 'Delete',
            icon: _isDeleting
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: textTheme.headlineSmall),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.work_outline),
                      label: Text(entry.category.label),
                    ),
                    if (entry.isOngoing)
                      Chip(
                        avatar: const Icon(Icons.schedule),
                        label: const Text('Ongoing'),
                        backgroundColor: colorScheme.secondaryContainer,
                      )
                    else
                      const Chip(
                        avatar: Icon(Icons.check_circle_outline),
                        label: Text('Completed'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (startedAt != null)
                  DetailRow(
                    label: 'Added',
                    value: localizations.formatShortDate(startedAt),
                  ),
                if (endedAt != null)
                  DetailRow(
                    label: 'End date',
                    value: localizations.formatShortDate(endedAt),
                  ),
                DetailRow(label: 'Thumbnail', value: entry.thumbnail ?? 'None'),
                const SizedBox(height: 16),
                Text('Description', style: textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(entry.description),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
