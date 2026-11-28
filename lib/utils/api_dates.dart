String formatApiDate(DateTime date) {
  final String year = date.year.toString().padLeft(4, '0');
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String formatApiDateTime(DateTime date) => '${formatApiDate(date)}T00:00:00';

DateTime parseApiDate(String value) => DateTime.parse(value.substring(0, 10));

DateTime? parseOptionalApiDate(String? value) =>
    value == null ? null : parseApiDate(value);

String? formatOptionalApiDate(DateTime? date) =>
    date == null ? null : formatApiDate(date);

String? formatOptionalApiDateTime(DateTime? date) =>
    date == null ? null : formatApiDateTime(date);
