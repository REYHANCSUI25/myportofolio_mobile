import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/date_form_field.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  static const double _maxFormWidth = 600;

  final _formKey = GlobalKey<FormState>();
  final _startDateKey = GlobalKey<FormFieldState<DateTime>>();

  String _institution = '';
  String _degree = '';
  String _description = '';
  DateTime? _startedAt;
  DateTime? _endedAt;

  InputDecoration _decoration(String labelText, String hintText) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  String? _required(String? value, String message) {
    return value == null || value.trim().isEmpty ? message : null;
  }

  String? _validateEndDate(DateTime? endedAt) {
    final DateTime? startedAt = _startDateKey.currentState?.value;
    if (endedAt != null && startedAt != null && endedAt.isBefore(startedAt)) {
      return "The end date can't be before the start date.";
    }
    return null;
  }

  void _save() {
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

    showDialog<void>(
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
              onPressed: () {
                Navigator.pop(dialogContext);
                _formKey.currentState!.reset();
              },
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
        title: const Text('Add Education Form'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
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
                      decoration: _decoration(
                        'Institution',
                        'Example: Universitas Indonesia',
                      ),
                      validator: (value) =>
                          _required(value, 'Enter the institution.'),
                      onSaved: (value) => _institution = value!.trim(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      maxLength: 255,
                      decoration: _decoration(
                        'Degree',
                        'Example: Bachelor of Computer Science',
                      ),
                      validator: (value) =>
                          _required(value, 'Enter the degree.'),
                      onSaved: (value) => _degree = value!.trim(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      maxLines: 5,
                      decoration: _decoration(
                        'Description',
                        'What you studied or achieved there',
                      ),
                      validator: (value) =>
                          _required(value, 'Enter a description.'),
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
