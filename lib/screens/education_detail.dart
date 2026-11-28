import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/widgets/detail_row.dart';

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
                DetailRow(
                  label: 'Start date',
                  value: localizations.formatShortDate(entry.startedAt),
                ),
                if (endedAt != null)
                  DetailRow(
                    label: 'End date',
                    value: localizations.formatShortDate(endedAt),
                  ),
                DetailRow(label: 'Stars', value: '${entry.starCount}'),
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
