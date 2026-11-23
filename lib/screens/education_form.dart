import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/utils/unsaved_changes_guard.dart';
import 'package:myportofolio_mobile/utils/validators.dart';
import 'package:myportofolio_mobile/widgets/date_form_field.dart';
import 'package:myportofolio_mobile/widgets/form_decoration.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage>
    with UnsavedChangesGuard<EducationFormPage> {
  static const double _maxFormWidth = 600;

  final _formKey = GlobalKey<FormState>();
  final _startDateKey = GlobalKey<FormFieldState<DateTime>>();

  String _institution = '';
  String _degree = '';
  String _description = '';
  DateTime? _startedAt;
  DateTime? _endedAt;

  String? _validateEndDate(DateTime? endedAt) {
    return validateDateOrder(_startDateKey.currentState?.value, endedAt);
  }

  Future<void> _save() async {
    final FormState form = _formKey.currentState!;
    if (!form.validate()) {
      return;
    }
    form.save();

    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final DateTime? endedAt = _endedAt;
    final String endDate = endedAt == null
        ? 'Present'
        : localizations.formatShortDate(endedAt);
    final List<String> summary = [
      'Institution: $_institution',
      'Degree: $_degree',
      'Description: $_description',
      'Start date: ${localizations.formatShortDate(_startedAt!)}',
      'End date: $endDate',
    ];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Education entry added successfully!'),
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
        title: const Text('Add Education Form'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      drawer: LeftDrawer(
        currentPage: DrawerPage.addEducation,
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
                        'Institution',
                        hintText: 'Example: Universitas Indonesia',
                      ),
                      validator: (value) =>
                          validateRequired(value, 'Enter the institution.'),
                      onSaved: (value) => _institution = value!.trim(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      maxLength: 255,
                      textInputAction: TextInputAction.next,
                      decoration: formFieldDecoration(
                        'Degree',
                        hintText: 'Example: Bachelor of Computer Science',
                      ),
                      validator: (value) =>
                          validateRequired(value, 'Enter the degree.'),
                      onSaved: (value) => _degree = value!.trim(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      maxLines: 5,
                      decoration: formFieldDecoration(
                        'Description',
                        hintText: 'What you studied or achieved there',
                      ),
                      validator: (value) =>
                          validateRequired(value, 'Enter a description.'),
                      onSaved: (value) => _description = value!.trim(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DateFormField(
                      key: _startDateKey,
                      labelText: 'Start Date',
                      validator: (value) =>
                          value == null ? 'Choose a start date.' : null,
                      onSaved: (value) => _startedAt = value,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DateFormField(
                      labelText: 'End Date',
                      helperText: "Leave empty if you're still studying here.",
                      clearable: true,
                      validator: _validateEndDate,
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
