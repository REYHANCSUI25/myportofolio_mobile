import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/models/experience_category.dart';

import 'fake_backend.dart';

void main() {
  group('Experience.fromJson', () {
    test('reads every field the API sends', () {
      final Experience entry = Experience.fromJson(experienceJson());

      expect(entry.id, 'ta');
      expect(entry.title, 'PBP Teaching Assistant');
      expect(entry.category, ExperienceCategory.partTime);
      expect(entry.description, 'Help students understand web development.');
      expect(entry.thumbnail, isNull);
      expect(entry.startedAt, DateTime(2026, 11, 20));
      expect(entry.endedAt, isNull);
      expect(entry.isOngoing, isTrue);
    });

    test('reads a thumbnail and an end date', () {
      final Experience entry = Experience.fromJson(
        experienceJson(
          thumbnail: 'https://example.com/ta.png',
          endedAt: '2025-06-30T00:00:00Z',
        ),
      );

      expect(entry.thumbnail, 'https://example.com/ta.png');
      expect(entry.endedAt, DateTime(2025, 6, 30));
      expect(entry.isOngoing, isFalse);
    });

    test('falls back to Full-Time when the category is missing', () {
      final Map<String, Object?> json = experienceJson()..remove('category');

      expect(Experience.fromJson(json).category, ExperienceCategory.fullTime);
    });
  });

  group('Experience.toJson', () {
    test('sends only the fields the API lets you write', () {
      final Experience entry = Experience(
        id: 'ta',
        title: 'PBP Teaching Assistant',
        category: ExperienceCategory.partTime,
        description: 'Help students understand web development.',
        thumbnail: 'https://example.com/ta.png',
        startedAt: DateTime(2026, 11, 20),
        endedAt: DateTime(2025, 6, 30),
      );

      expect(entry.toJson(), {
        'title': 'PBP Teaching Assistant',
        'category': 'part-time',
        'description': 'Help students understand web development.',
        'thumbnail': 'https://example.com/ta.png',
        'ended_at': '2025-06-30T00:00:00',
      });
    });

    test('sends a missing thumbnail and end date as null', () {
      const Experience entry = Experience(
        title: 'Volunteer Tutor',
        description: 'Taught kids.',
      );

      expect(entry.toJson(), containsPair('thumbnail', null));
      expect(entry.toJson(), containsPair('ended_at', null));
      expect(entry.toJson(), containsPair('category', 'full-time'));
    });

    test('every category goes back and forth as its Django value', () {
      for (final category in ExperienceCategory.values) {
        final Experience entry = Experience(
          title: 'Title',
          category: category,
          description: 'Description',
        );
        final Map<String, dynamic> json = entry.toJson();

        expect(json['category'], category.value);
        expect(Experience.fromJson(json).category, category);
      }
    });
  });
}
