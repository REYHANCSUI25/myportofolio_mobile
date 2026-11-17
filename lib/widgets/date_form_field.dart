import 'package:material_ui/material_ui.dart';

class DateFormField extends FormField<DateTime> {
  DateFormField({
    super.key,
    required String labelText,
    String? helperText,
    bool clearable = false,
    super.onSaved,
    super.validator,
  }) : super(
         builder: (field) {
           final DateTime? date = field.value;
           final BorderRadius borderRadius = BorderRadius.circular(5.0);

           return InkWell(
             borderRadius: borderRadius,
             onTap: () async {
               final DateTime? picked = await showDatePicker(
                 context: field.context,
                 initialDate: date,
                 firstDate: DateTime(1950),
                 lastDate: DateTime(2100, 12, 31),
               );
               if (picked != null && field.mounted) {
                 field.didChange(picked);
               }
             },
             child: InputDecorator(
               isEmpty: date == null,
               decoration: InputDecoration(
                 labelText: labelText,
                 helperText: helperText,
                 errorText: field.errorText,
                 border: OutlineInputBorder(borderRadius: borderRadius),
                 suffixIcon: clearable && date != null
                     ? IconButton(
                         icon: const Icon(Icons.clear),
                         tooltip: 'Clear date',
                         onPressed: () => field.didChange(null),
                       )
                     : const Icon(Icons.calendar_today),
               ),
               child: Text(
                 date == null
                     ? ''
                     : MaterialLocalizations.of(field.context)
                           .formatShortDate(date),
               ),
             ),
           );
         },
       );
}
