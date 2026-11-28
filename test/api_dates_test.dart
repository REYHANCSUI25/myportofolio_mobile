import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/utils/api_dates.dart';

void main() {
  test('formatApiDate writes YYYY-MM-DD and drops the time', () {
    expect(formatApiDate(DateTime(2025, 8, 1)), '2025-08-01');
    expect(formatApiDate(DateTime(2025, 12, 31, 23, 59)), '2025-12-31');
  });

  test('formatApiDateTime writes midnight without a time zone', () {
    expect(formatApiDateTime(DateTime(2025, 6, 30)), '2025-06-30T00:00:00');
    expect(formatApiDateTime(DateTime(2025, 6, 30, 18)), '2025-06-30T00:00:00');
  });

  test('parseApiDate reads the date from a date or a timestamp', () {
    expect(parseApiDate('2025-08-01'), DateTime(2025, 8, 1));
    expect(parseApiDate('2026-11-20T23:30:00.123456Z'), DateTime(2026, 11, 20));
  });

  test('the optional versions pass null through', () {
    expect(parseOptionalApiDate(null), isNull);
    expect(formatOptionalApiDate(null), isNull);
    expect(formatOptionalApiDateTime(null), isNull);
    expect(parseOptionalApiDate('2025-06-30T00:00:00Z'), DateTime(2025, 6, 30));
  });
}
