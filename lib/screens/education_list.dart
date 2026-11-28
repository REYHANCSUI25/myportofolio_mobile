import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/screens/education_detail.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/utils/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/empty_list_message.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/load_error_message.dart';
import 'package:provider/provider.dart';

class EducationListPage extends StatefulWidget {
  const EducationListPage({super.key});

  @override
  State<EducationListPage> createState() => _EducationListPageState();
}

class _EducationListPageState extends State<EducationListPage> {
  late Future<List<Education>> _entries;

  @override
  void initState() {
    super.initState();
    _entries = context.read<ApiClient>().getEducationList();
  }

  Future<void> _reload() async {
    final ApiClient api = context.read<ApiClient>();
    final Future<List<Education>> entries = api.getEducationList();
    setState(() {
      _entries = entries;
    });
    try {
      await entries;
    } catch (_) {}
  }

  Future<void> _add() async {
    final NavigatorState navigator = Navigator.of(context);
    if (!await ensureLoggedIn(context)) {
      return;
    }
    await navigator.push(
      MaterialPageRoute(builder: (context) => const EducationFormPage()),
    );
    if (mounted) {
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Education'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      drawer: const LeftDrawer(currentPage: DrawerPage.viewEducation),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        tooltip: 'Add a new education entry',
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: FutureBuilder<List<Education>>(
        future: _entries,
        builder: (context, snapshot) {
          final bool isLoading =
              snapshot.connectionState == ConnectionState.waiting;
          if (isLoading && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return LoadErrorMessage(
              title: "Couldn't load the education entries.",
              error: snapshot.error!,
              onRetry: _reload,
            );
          }

          final List<Education> entries = snapshot.data ?? const [];
          return RefreshIndicator(
            onRefresh: _reload,
            child: entries.isEmpty
                ? const EmptyListMessage('No education entries yet.')
                : _EntryList(entries: entries),
          );
        },
      ),
    );
  }
}

String _educationPeriod(BuildContext context, Education entry) {
  final MaterialLocalizations localizations = MaterialLocalizations.of(context);
  final DateTime? endedAt = entry.endedAt;
  final String start = localizations.formatMonthYear(entry.startedAt);
  final String end = endedAt == null
      ? 'Present'
      : localizations.formatMonthYear(endedAt);
  return '$start – $end';
}

class _EntryList extends StatelessWidget {
  final List<Education> entries;

  const _EntryList({required this.entries});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
      itemCount: entries.length,
      itemBuilder: (context, index) => _EducationCard(entry: entries[index]),
    );
  }
}

class _EducationCard extends StatelessWidget {
  final Education entry;

  const _EducationCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EducationDetailPage(entry: entry),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.degree, style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(entry.institution),
                  const SizedBox(height: 4),
                  Text(
                    _educationPeriod(context, entry),
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
