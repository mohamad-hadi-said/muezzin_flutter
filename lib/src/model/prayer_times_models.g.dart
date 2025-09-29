// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_times_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrayerTimesResponse _$PrayerTimesResponseFromJson(Map<String, dynamic> json) =>
    PrayerTimesResponse(
      code: (json['code'] as num?)?.toInt(),
      status: json['status'] as String?,
      data: json['data'] == null
          ? null
          : PrayerTimesData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PrayerTimesResponseToJson(
  PrayerTimesResponse instance,
) => <String, dynamic>{
  'code': instance.code,
  'status': instance.status,
  'data': instance.data,
};

PrayerTimesListResponse _$PrayerTimesListResponseFromJson(
  Map<String, dynamic> json,
) => PrayerTimesListResponse(
  code: (json['code'] as num?)?.toInt(),
  status: json['status'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => PrayerTimesData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PrayerTimesListResponseToJson(
  PrayerTimesListResponse instance,
) => <String, dynamic>{
  'code': instance.code,
  'status': instance.status,
  'data': instance.data,
};

PrayerTimesData _$PrayerTimesDataFromJson(Map<String, dynamic> json) =>
    PrayerTimesData(
      timings: json['timings'] == null
          ? null
          : PrayerTimings.fromJson(json['timings'] as Map<String, dynamic>),
      date: json['date'] == null
          ? null
          : DateInfo.fromJson(json['date'] as Map<String, dynamic>),
      meta: json['meta'] == null
          ? null
          : MetaInfo.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PrayerTimesDataToJson(PrayerTimesData instance) =>
    <String, dynamic>{
      'timings': instance.timings,
      'date': instance.date,
      'meta': instance.meta,
    };

PrayerTimings _$PrayerTimingsFromJson(Map<String, dynamic> json) =>
    PrayerTimings(
      fajr: json['Fajr'] as String?,
      sunrise: json['Sunrise'] as String?,
      dhuhr: json['Dhuhr'] as String?,
      asr: json['Asr'] as String?,
      sunset: json['Sunset'] as String?,
      maghrib: json['Maghrib'] as String?,
      isha: json['Isha'] as String?,
      imsak: json['Imsak'] as String?,
      midnight: json['Midnight'] as String?,
      firstThird: json['Firstthird'] as String?,
      lastThird: json['Lastthird'] as String?,
    );

Map<String, dynamic> _$PrayerTimingsToJson(PrayerTimings instance) =>
    <String, dynamic>{
      'Fajr': instance.fajr,
      'Sunrise': instance.sunrise,
      'Dhuhr': instance.dhuhr,
      'Asr': instance.asr,
      'Sunset': instance.sunset,
      'Maghrib': instance.maghrib,
      'Isha': instance.isha,
      'Imsak': instance.imsak,
      'Midnight': instance.midnight,
      'Firstthird': instance.firstThird,
      'Lastthird': instance.lastThird,
    };

WeekdayInfo _$WeekdayInfoFromJson(Map<String, dynamic> json) =>
    WeekdayInfo(en: json['en'] as String?, ar: json['ar'] as String?);

Map<String, dynamic> _$WeekdayInfoToJson(WeekdayInfo instance) =>
    <String, dynamic>{'en': instance.en, 'ar': instance.ar};

MonthInfo _$MonthInfoFromJson(Map<String, dynamic> json) => MonthInfo(
  number: (json['number'] as num?)?.toInt(),
  en: json['en'] as String?,
  ar: json['ar'] as String?,
  days: (json['days'] as num?)?.toInt(),
);

Map<String, dynamic> _$MonthInfoToJson(MonthInfo instance) => <String, dynamic>{
  'number': instance.number,
  'en': instance.en,
  'ar': instance.ar,
  'days': instance.days,
};

HijriInfo _$HijriInfoFromJson(Map<String, dynamic> json) => HijriInfo(
  date: json['date'] as String?,
  day: json['day'] as String?,
  weekday: json['weekday'] == null
      ? null
      : WeekdayInfo.fromJson(json['weekday'] as Map<String, dynamic>),
  month: json['month'] == null
      ? null
      : MonthInfo.fromJson(json['month'] as Map<String, dynamic>),
  year: json['year'] as String?,
  method: json['method'] as String?,
);

Map<String, dynamic> _$HijriInfoToJson(HijriInfo instance) => <String, dynamic>{
  'date': instance.date,
  'day': instance.day,
  'weekday': instance.weekday,
  'month': instance.month,
  'year': instance.year,
  'method': instance.method,
};

GregorianInfo _$GregorianInfoFromJson(Map<String, dynamic> json) =>
    GregorianInfo(
      date: json['date'] as String?,
      day: json['day'] as String?,
      weekday: json['weekday'] == null
          ? null
          : WeekdayInfo.fromJson(json['weekday'] as Map<String, dynamic>),
      month: json['month'] == null
          ? null
          : MonthInfo.fromJson(json['month'] as Map<String, dynamic>),
      year: json['year'] as String?,
    );

Map<String, dynamic> _$GregorianInfoToJson(GregorianInfo instance) =>
    <String, dynamic>{
      'date': instance.date,
      'day': instance.day,
      'weekday': instance.weekday,
      'month': instance.month,
      'year': instance.year,
    };

DateInfo _$DateInfoFromJson(Map<String, dynamic> json) => DateInfo(
  readable: json['readable'] as String?,
  timestamp: json['timestamp'] as String?,
  hijri: json['hijri'] == null
      ? null
      : HijriInfo.fromJson(json['hijri'] as Map<String, dynamic>),
  gregorian: json['gregorian'] == null
      ? null
      : GregorianInfo.fromJson(json['gregorian'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DateInfoToJson(DateInfo instance) => <String, dynamic>{
  'readable': instance.readable,
  'timestamp': instance.timestamp,
  'hijri': instance.hijri,
  'gregorian': instance.gregorian,
};

MethodParams _$MethodParamsFromJson(Map<String, dynamic> json) =>
    MethodParams(fajr: json['Fajr'], isha: json['Isha']);

Map<String, dynamic> _$MethodParamsToJson(MethodParams instance) =>
    <String, dynamic>{'Fajr': instance.fajr, 'Isha': instance.isha};

MethodInfo _$MethodInfoFromJson(Map<String, dynamic> json) => MethodInfo(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  params: json['params'] == null
      ? null
      : MethodParams.fromJson(json['params'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MethodInfoToJson(MethodInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'params': instance.params,
    };

MetaInfo _$MetaInfoFromJson(Map<String, dynamic> json) => MetaInfo(
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  timezone: json['timezone'] as String?,
  method: json['method'] == null
      ? null
      : MethodInfo.fromJson(json['method'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MetaInfoToJson(MetaInfo instance) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'timezone': instance.timezone,
  'method': instance.method,
};
