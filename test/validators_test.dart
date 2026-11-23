import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/utils/validators.dart';

void main() {
  group('validateRequired', () {
    test('rejects missing, empty and blank text', () {
      expect(validateRequired(null, 'Required.'), 'Required.');
      expect(validateRequired('', 'Required.'), 'Required.');
      expect(validateRequired('   ', 'Required.'), 'Required.');
    });

    test('accepts text with visible characters', () {
      expect(validateRequired(' Teaching Assistant ', 'Required.'), isNull);
    });
  });

  group('validateOptionalLink', () {
    test('accepts an empty value and http or https links', () {
      expect(validateOptionalLink(null), isNull);
      expect(validateOptionalLink('   '), isNull);
      expect(validateOptionalLink('https://example.com/photo.png'), isNull);
      expect(validateOptionalLink('http://example.com'), isNull);
    });

    test('rejects text that is not a web link', () {
      expect(validateOptionalLink('example.com'), isNotNull);
      expect(validateOptionalLink('ftp://example.com'), isNotNull);
      expect(validateOptionalLink('https://'), isNotNull);
      expect(validateOptionalLink('not a link'), isNotNull);
    });
  });

  group('validateDateOrder', () {
    test('rejects an end date before the start date', () {
      expect(
        validateDateOrder(DateTime(2025, 8, 25), DateTime(2025, 8, 24)),
        isNotNull,
      );
    });

    test('accepts a missing date or an end on or after the start', () {
      expect(validateDateOrder(DateTime(2025, 8, 25), null), isNull);
      expect(validateDateOrder(null, DateTime(2025, 8, 24)), isNull);
      expect(
        validateDateOrder(DateTime(2025, 8, 25), DateTime(2025, 8, 25)),
        isNull,
      );
    });
  });
}
