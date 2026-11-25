import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/education.dart';

class EducationDetailPage extends StatelessWidget {
  final Education entry;

  const EducationDetailPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final DateTime? endedAt = entry.endedAt;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Education Details'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.degree, style: textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(entry.institution, style: textTheme.titleMedium),
                const SizedBox(height: 12),
                if (entry.isOngoing)
                  Chip(
                    avatar: const Icon(Icons.schedule),
                    label: const Text('Ongoing'),
                    backgroundColor: colorScheme.secondaryContainer,
                  ),
                const SizedBox(height: 12),
                _DetailRow(
                  label: 'Start date',
                  value: localizations.formatShortDate(entry.startedAt),
                ),
                if (endedAt != null)
                  _DetailRow(
                    label: 'End date',
                    value: localizations.formatShortDate(endedAt),
                  ),
                _DetailRow(label: 'Stars', value: '${entry.starCount}'),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
