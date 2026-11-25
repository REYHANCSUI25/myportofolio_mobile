import 'package:json_annotation/json_annotation.dart';

part 'education.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Education {
  @JsonKey(includeToJson: false)
  final String? id;
  final String institution;
  final String degree;
  final String description;
  @JsonKey(fromJson: _dateFromJson, toJson: formatApiDate)
  final DateTime startedAt;
  @JsonKey(fromJson: _optionalDateFromJson, toJson: _optionalDateToJson)
  final DateTime? endedAt;
  @JsonKey(includeToJson: false)
  final int starCount;
  @JsonKey(includeToJson: false)
  final bool isStarred;

  const Education({
    this.id,
    required this.institution,
    required this.degree,
    required this.description,
    required this.startedAt,
    this.endedAt,
    this.starCount = 0,
    this.isStarred = false,
  });

  factory Education.fromJson(Map<String, dynamic> json) =>
      _$EducationFromJson(json);

  bool get isOngoing => endedAt == null;

  Map<String, dynamic> toJson() => _$EducationToJson(this);
}

String formatApiDate(DateTime date) {
  final String year = date.year.toString().padLeft(4, '0');
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

DateTime _dateFromJson(String value) => DateTime.parse(value);

DateTime? _optionalDateFromJson(String? value) =>
    value == null ? null : DateTime.parse(value);

String? _optionalDateToJson(DateTime? date) =>
    date == null ? null : formatApiDate(date);
