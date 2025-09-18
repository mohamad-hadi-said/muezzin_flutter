import 'package:freezed_annotation/freezed_annotation.dart';

part 'azkar_model.g.dart';

@JsonSerializable()
class MuezzinModel {
  int? id;
  String? text;
  int? repetitions;
  int? order;
  @JsonKey(name: 'is_favorite')
  bool? isFavorite;
  int? type;

  MuezzinModel({
     this.id,
     this.text,
     this.repetitions,
     this.order,
     this.isFavorite,
     this.type,
  });

  Map<String, dynamic> toJson() => _$MuezzinModelToJson(this);

  factory MuezzinModel.fromJson(Map<String, dynamic> json) => _$MuezzinModelFromJson(json);

}
