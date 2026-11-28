import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/education.dart';
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
  bool _isSubmitting = false;

  String? _validateEndDate(DateTime? endedAt) {
    return validateDateOrder(_startDateKey.currentState?.value, endedAt);
  }

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
    final Education entry = Education(
      institution: _institution,
      degree: _degree,
      description: _description,
      startedAt: _startedAt!,
      endedAt: _endedAt,
    );

    setState(() => _isSubmitting = true);
    Education? saved;
    try {
      saved = await requestWithLogin(
        navigator,
        auth,
        (token) => api.createEducation(entry, token: token),
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

  Future<void> _showSummary(Education saved) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final DateTime? endedAt = saved.endedAt;
    final String endDate = endedAt == null
        ? 'Present'
        : localizations.formatShortDate(endedAt);
    final List<String> summary = [
      'Institution: ${saved.institution}',
      'Degree: ${saved.degree}',
      'Description: ${saved.description}',
      'Start date: ${localizations.formatShortDate(saved.startedAt)}',
      'End date: $endDate',
    ];

    return showDialog<void>(
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
