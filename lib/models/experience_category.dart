import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum ExperienceCategory {
  internship('internship', 'Internship'),
  research('research', 'Research'),
  volunteer('volunteer', 'Volunteer'),
  partTime('part-time', 'Part-Time'),
  fullTime('full-time', 'Full-Time'),
  freelance('freelance', 'Freelance');

  final String value;
  final String label;

  const ExperienceCategory(this.value, this.label);
}
