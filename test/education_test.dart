import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/education.dart';

import 'fake_backend.dart';

void main() {
  group('Education.fromJson', () {
    test('reads every field the API sends', () {
      final Education entry = Education.fromJson(educationJson());

      expect(entry.id, 'ui');
      expect(entry.institution, 'Universitas Indonesia');
      expect(entry.degree, 'S1 Ilmu Komputer KKI');
      expect(entry.description, 'Studying computer science.');
      expect(entry.startedAt, DateTime(2025, 8, 1));
      expect(entry.endedAt, isNull);
      expect(entry.isOngoing, isTrue);
      expect(entry.starCount, 1);
      expect(entry.isStarred, isFalse);
    });

    test('reads an end date', () {
      final Education entry = Education.fromJson(
        educationJson(endedAt: '2029-07-31'),
      );

      expect(entry.endedAt, DateTime(2029, 7, 31));
      expect(entry.isOngoing, isFalse);
    });
  });

  group('Education.toJson', () {
    test('sends only the fields the API lets you write', () {
      final Education entry = Education(
        id: 'ui',
        institution: 'Universitas Indonesia',
        degree: 'S1 Ilmu Komputer KKI',
        description: 'Studying computer science.',
        startedAt: DateTime(2025, 8, 1),
        endedAt: DateTime(2029, 7, 31),
        starCount: 5,
        isStarred: true,
      );

      expect(entry.toJson(), {
        'institution': 'Universitas Indonesia',
        'degree': 'S1 Ilmu Komputer KKI',
        'description': 'Studying computer science.',
        'started_at': '2025-08-01',
        'ended_at': '2029-07-31',
      });
    });

    test('sends a missing end date as null', () {
      final Education entry = Education(
        institution: 'Universitas Indonesia',
        degree: 'S1 Ilmu Komputer KKI',
        description: 'Studying computer science.',
        startedAt: DateTime(2025, 8, 1),
      );

      expect(entry.toJson(), containsPair('ended_at', null));
    });
  });
}
