import 'package:json_annotation/json_annotation.dart';
import 'package:myportofolio_mobile/utils/api_dates.dart';

part 'education.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Education {
  @JsonKey(includeToJson: false)
  final String? id;
  final String institution;
  final String degree;
  final String description;
  @JsonKey(fromJson: parseApiDate, toJson: formatApiDate)
  final DateTime startedAt;
  @JsonKey(fromJson: parseOptionalApiDate, toJson: formatOptionalApiDate)
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
