import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/experience_detail.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/utils/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/empty_list_message.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/load_error_message.dart';
import 'package:provider/provider.dart';

class ExperienceListPage extends StatefulWidget {
  const ExperienceListPage({super.key});

  @override
  State<ExperienceListPage> createState() => _ExperienceListPageState();
}

class _ExperienceListPageState extends State<ExperienceListPage> {
  late Future<List<Experience>> _entries;

  @override
  void initState() {
    super.initState();
    _entries = context.read<ApiClient>().getExperienceList();
  }

  Future<void> _reload() async {
    final ApiClient api = context.read<ApiClient>();
    final Future<List<Experience>> entries = api.getExperienceList();
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
      MaterialPageRoute(builder: (context) => const ExperienceFormPage()),
    );
    if (mounted) {
      await _reload();
    }
  }

  Future<void> _open(Experience entry) async {
    final bool? deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ExperienceDetailPage(entry: entry),
      ),
    );
    if (deleted == true && mounted) {
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Experience'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      drawer: const LeftDrawer(currentPage: DrawerPage.viewExperience),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        tooltip: 'Add a new experience entry',
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: FutureBuilder<List<Experience>>(
        future: _entries,
        builder: (context, snapshot) {
          final bool isLoading =
              snapshot.connectionState == ConnectionState.waiting;
          if (isLoading && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return LoadErrorMessage(
              title: "Couldn't load the experience entries.",
              error: snapshot.error!,
              onRetry: _reload,
            );
          }

          final List<Experience> entries = snapshot.data ?? const [];
          return RefreshIndicator(
            onRefresh: _reload,
            child: entries.isEmpty
                ? const EmptyListMessage('No experience entries yet.')
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
                    itemCount: entries.length,
                    itemBuilder: (context, index) => _ExperienceCard(
                      entry: entries[index],
                      onTap: () => _open(entries[index]),
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final Experience entry;
  final VoidCallback onTap;

  const _ExperienceCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DateTime? endedAt = entry.endedAt;
    final String status = endedAt == null
        ? 'Ongoing'
        : 'Ended ${MaterialLocalizations.of(context).formatShortDate(endedAt)}';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title, style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(entry.category.label),
                  const SizedBox(height: 4),
                  Text(status, style: textTheme.bodySmall),
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
