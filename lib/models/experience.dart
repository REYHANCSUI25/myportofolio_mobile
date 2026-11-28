import 'package:json_annotation/json_annotation.dart';
import 'package:myportofolio_mobile/models/experience_category.dart';
import 'package:myportofolio_mobile/utils/api_dates.dart';

part 'experience.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Experience {
  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final ExperienceCategory category;
  final String description;
  final String? thumbnail;
  @JsonKey(includeToJson: false, fromJson: parseOptionalApiDate)
  final DateTime? startedAt;
  @JsonKey(fromJson: parseOptionalApiDate, toJson: formatOptionalApiDateTime)
  final DateTime? endedAt;

  const Experience({
    this.id,
    required this.title,
    this.category = ExperienceCategory.fullTime,
    required this.description,
    this.thumbnail,
    this.startedAt,
    this.endedAt,
  });

  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);

  bool get isOngoing => endedAt == null;

  Map<String, dynamic> toJson() => _$ExperienceToJson(this);
}
