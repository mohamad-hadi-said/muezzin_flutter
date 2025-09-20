import 'package:freezed_annotation/freezed_annotation.dart';

part 'prayer_times_models.g.dart';

@JsonSerializable()
class PrayerTimesResponse {
  int? code;
  String? status;
  PrayerTimesData? data;
  PrayerTimesResponse({this.code, this.status, this.data});
  Map<String, dynamic> toJson() => _$PrayerTimesResponseToJson(this);

  factory PrayerTimesResponse.fromJson(Map<String, dynamic> json) =>
      _$PrayerTimesResponseFromJson(json);
}

@JsonSerializable()
class PrayerTimesData {
  PrayerTimings? timings;
  DateInfo? date;
  MetaInfo? meta;
  PrayerTimesData({this.timings, this.date, this.meta});
  Map<String, dynamic> toJson() => _$PrayerTimesDataToJson(this);

  factory PrayerTimesData.fromJson(Map<String, dynamic> json) =>
      _$PrayerTimesDataFromJson(json);
}

@JsonSerializable()
class PrayerTimings {
  @JsonKey(name: 'Fajr')
  String? fajr;
  @JsonKey(name: 'Sunrise')
  String? sunrise;
  @JsonKey(name: 'Dhuhr')
  String? dhuhr;
  @JsonKey(name: 'Asr')
  String? asr;
  @JsonKey(name: 'Sunset')
  String? sunset;
  @JsonKey(name: 'Maghrib')
  String? maghrib;
  @JsonKey(name: 'Isha')
  String? isha;
  @JsonKey(name: 'Imsak')
  String? imsak;
  @JsonKey(name: 'Midnight')
  String? midnight;
  @JsonKey(name: 'Firstthird')
  String? firstThird; // Some methods may not return these
  @JsonKey(name: 'Lastthird')
  String? lastThird;

  PrayerTimings({
    this.fajr,
    this.sunrise,
    this.dhuhr,
    this.asr,
    this.sunset,
    this.maghrib,
    this.isha,
    this.imsak,
    this.midnight,
    this.firstThird,
    this.lastThird,
  });

  Map<String, dynamic> toJson() => _$PrayerTimingsToJson(this);

  factory PrayerTimings.fromJson(Map<String, dynamic> json) =>
      _$PrayerTimingsFromJson(json);
}

@JsonSerializable()
class WeekdayInfo {
  String? en;
  String? ar;
  WeekdayInfo({this.en, this.ar});
  Map<String, dynamic> toJson() => _$WeekdayInfoToJson(this);

  factory WeekdayInfo.fromJson(Map<String, dynamic> json) =>
      _$WeekdayInfoFromJson(json);
}

@JsonSerializable()
class MonthInfo {
  int? number;
  String? en;
  String? ar;
  int? days;
  MonthInfo({this.number, this.en, this.ar, this.days});
  Map<String, dynamic> toJson() => _$MonthInfoToJson(this);

  factory MonthInfo.fromJson(Map<String, dynamic> json) =>
      _$MonthInfoFromJson(json);
}

@JsonSerializable()
class HijriInfo {
  String? date; // DD-MM-YYYY
  String? day;
  WeekdayInfo? weekday;
  MonthInfo? month;
  String? year;
  String? method; // e.g., HJCoSA if present
  HijriInfo({
    this.date,
    this.day,
    this.weekday,
    this.month,
    this.year,
    this.method,
  });
  Map<String, dynamic> toJson() => _$HijriInfoToJson(this);

  factory HijriInfo.fromJson(Map<String, dynamic> json) =>
      _$HijriInfoFromJson(json);
}

@JsonSerializable()
class GregorianInfo {
  String? date; // DD-MM-YYYY
  String? day;
  WeekdayInfo? weekday;
  MonthInfo? month;
  String? year;
  GregorianInfo({this.date, this.day, this.weekday, this.month, this.year});
  Map<String, dynamic> toJson() => _$GregorianInfoToJson(this);

  factory GregorianInfo.fromJson(Map<String, dynamic> json) =>
      _$GregorianInfoFromJson(json);
}

@JsonSerializable()
class DateInfo {
  String? readable;
  String? timestamp;
  HijriInfo? hijri;
  GregorianInfo? gregorian;
  DateInfo({this.readable, this.timestamp, this.hijri, this.gregorian});

  Map<String, dynamic> toJson() => _$DateInfoToJson(this);

  factory DateInfo.fromJson(Map<String, dynamic> json) =>
      _$DateInfoFromJson(json);
}

@JsonSerializable()
class MethodParams {
  @JsonKey(name: 'Fajr')
  dynamic fajr;
  @JsonKey(name: 'Isha')
  dynamic isha;
  MethodParams({this.fajr, this.isha});
  Map<String, dynamic> toJson() => _$MethodParamsToJson(this);

  factory MethodParams.fromJson(Map<String, dynamic> json) =>
      _$MethodParamsFromJson(json);
}

@JsonSerializable()
class MethodInfo {
  int? id;
  String? name;
  MethodParams? params;
  MethodInfo({this.id, this.name, this.params});
  Map<String, dynamic> toJson() => _$MethodInfoToJson(this);

  factory MethodInfo.fromJson(Map<String, dynamic> json) =>
      _$MethodInfoFromJson(json);
}

@JsonSerializable()
class MetaInfo {
  double? latitude;
  double? longitude;
  String? timezone;
  MethodInfo? method;
  MetaInfo({this.latitude, this.longitude, this.timezone, this.method});
  Map<String, dynamic> toJson() => _$MetaInfoToJson(this);

  factory MetaInfo.fromJson(Map<String, dynamic> json) =>
      _$MetaInfoFromJson(json);
}
