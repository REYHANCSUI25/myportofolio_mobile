import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/models/experience_category.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/auth_guard.dart';
import 'package:myportofolio_mobile/utils/snack_bars.dart';
import 'package:myportofolio_mobile/utils/unsaved_changes_guard.dart';
import 'package:myportofolio_mobile/utils/validators.dart';
import 'package:myportofolio_mobile/widgets/date_form_field.dart';
import 'package:myportofolio_mobile/widgets/form_decoration.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage>
    with UnsavedChangesGuard<ExperienceFormPage> {
  static const double _maxFormWidth = 600;

  final _formKey = GlobalKey<FormState>();

  String _title = '';
  ExperienceCategory _category = ExperienceCategory.fullTime;
  String _description = '';
  String _thumbnail = '';
  DateTime? _endedAt;
  bool _isSubmitting = false;

  Future<void> _save() async {
    final FormState form = _formKey.currentState!;
    if (_isSubmitting || !form.validate()) {
      return;
    }
    form.save();

    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final ApiClient api = context.read<ApiClient>();
    final AuthState auth = context.read<AuthState>();
    final Experience entry = Experience(
      title: _title,
      category: _category,
      description: _description,
      thumbnail: _thumbnail.isEmpty ? null : _thumbnail,
      endedAt: _endedAt,
    );

    setState(() => _isSubmitting = true);
    Experience? saved;
    try {
      saved = await requestWithLogin(
        navigator,
        auth,
        (token) => api.createExperience(entry, token: token),
      );
    } on ApiException catch (error) {
      showSnackBarMessage(
        messenger,
        "Couldn't save (${error.statusCode}): ${error.message}",
      );
    } on http.ClientException catch (error) {
      showSnackBarMessage(messenger, describeError(error));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
    if (saved == null || !mounted) {
      return;
    }

    await _showSummary(saved);
    if (!mounted) {
      return;
    }
    form.reset();
    markSaved();
  }

  Future<void> _showSummary(Experience saved) {
    final DateTime? endedAt = saved.endedAt;
    final String endDate = endedAt == null
        ? 'Ongoing'
        : MaterialLocalizations.of(context).formatShortDate(endedAt);
    final List<String> summary = [
      'Title: ${saved.title}',
      'Category: ${saved.category.label}',
      'Description: ${saved.description}',
      'Thumbnail: ${saved.thumbnail ?? 'None'}',
      'End date: $endDate',
    ];

    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Experience added successfully!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (final line in summary) Text(line)],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Experience Form'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      drawer: LeftDrawer(
        currentPage: DrawerPage.addExperience,
        confirmLeave: confirmLeave,
      ),
      body: Form(
        key: _formKey,
        canPop: !hasUnsavedInput,
        onPopInvokedWithResult: handlePop,
        onChanged: markUnsaved,
        autovalidateMode: AutovalidateMode.onUserInteractionIfError,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxFormWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      maxLength: 255,
                      textInputAction: TextInputAction.next,
                      decoration: formFieldDecoration(
                        'Title',
                        hintText: 'Example: Teaching Assistant',
                      ),
                      validator: (value) =>
                          validateRequired(value, 'Enter a title.'),
                      onSaved: (value) => _title = value!.trim(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<ExperienceCategory>(
                      enabled: true,
                      isExpanded: true,
                      initialValue: ExperienceCategory.fullTime,
                      decoration: formFieldDecoration('Category'),
                      items: [
                        for (final category in ExperienceCategory.values)
                          DropdownMenuItem(
                            value: category,
                            child: Text(category.label),
                          ),
                      ],
                      validator: (value) =>
                          value == null ? 'Choose a category.' : null,
                      onSaved: (value) => _category = value!,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      maxLines: 5,
                      decoration: formFieldDecoration(
                        'Description',
                        hintText: 'What you did and what you learned',
                      ),
                      validator: (value) =>
                          validateRequired(value, 'Enter a description.'),
                      onSaved: (value) => _description = value!.trim(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      maxLength: 200,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.next,
                      decoration: formFieldDecoration(
                        'Thumbnail URL',
                        hintText: 'https://example.com/photo.png',
                        helperText: 'Optional: a link to an image.',
                      ),
                      validator: validateOptionalLink,
                      onSaved: (value) => _thumbnail = value!.trim(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DateFormField(
                      labelText: 'End Date',
                      helperText: "Leave empty if it's still ongoing.",
                      clearable: true,
                      onSaved: (value) => _endedAt = value,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FilledButton(
                        onPressed: _isSubmitting ? null : _save,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ),
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
