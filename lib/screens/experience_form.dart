import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience_category.dart';
import 'package:myportofolio_mobile/utils/unsaved_changes_guard.dart';
import 'package:myportofolio_mobile/utils/validators.dart';
import 'package:myportofolio_mobile/widgets/date_form_field.dart';
import 'package:myportofolio_mobile/widgets/form_decoration.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

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

  Future<void> _save() async {
    final FormState form = _formKey.currentState!;
    if (!form.validate()) {
      return;
    }
    form.save();

    final DateTime? endedAt = _endedAt;
    final String endDate = endedAt == null
        ? 'Ongoing'
        : MaterialLocalizations.of(context).formatShortDate(endedAt);
    final String thumbnail = _thumbnail.isEmpty ? 'None' : _thumbnail;
    final List<String> summary = [
      'Title: $_title',
      'Category: ${_category.label}',
      'Description: $_description',
      'Thumbnail: $thumbnail',
      'End date: $endDate',
    ];

    await showDialog<void>(
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
    if (!mounted) {
      return;
    }
    form.reset();
    markSaved();
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
                        onPressed: _save,
                        child: const Text('Save'),
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
