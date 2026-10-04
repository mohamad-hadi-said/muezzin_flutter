import 'dart:math' as math;

class OfflineCity {
  final String name;
  final double lat;
  final double lng;

  const OfflineCity({
    required this.name,
    required this.lat,
    required this.lng,
  });
}

class OfflineCitiesHelper {
  /// Major Syrian regions, districts, and major regional Arab cities
  static const List<OfflineCity> _cities = [
    // Syrian Cities & Towns
    OfflineCity(name: 'تل رفعت، حلب', lat: 36.4735, lng: 37.0963),
    OfflineCity(name: 'أعزاز، حلب', lat: 36.5869, lng: 37.0441),
    OfflineCity(name: 'عفرين، حلب', lat: 36.5126, lng: 36.8681),
    OfflineCity(name: 'مارع، حلب', lat: 36.4831, lng: 37.1969),
    OfflineCity(name: 'الباب، حلب', lat: 36.3711, lng: 37.5147),
    OfflineCity(name: 'منبج، حلب', lat: 36.5281, lng: 37.9550),
    OfflineCity(name: 'جرابلس، حلب', lat: 36.8203, lng: 38.0136),
    OfflineCity(name: 'عفرين، حلب', lat: 36.5126, lng: 36.8681),
    OfflineCity(name: 'حلب، سوريا', lat: 36.2021, lng: 37.1343),
    OfflineCity(name: 'سرمدا، إدلب', lat: 36.1833, lng: 36.7194),
    OfflineCity(name: 'الدانا، إدلب', lat: 36.2167, lng: 36.7722),
    OfflineCity(name: 'إدلب، سوريا', lat: 35.9306, lng: 36.6342),
    OfflineCity(name: 'أريحا، إدلب', lat: 35.8142, lng: 36.5919),
    OfflineCity(name: 'معرة النعمان، إدلب', lat: 35.6494, lng: 36.6744),
    OfflineCity(name: 'جسر الشغور، إدلب', lat: 35.8144, lng: 36.3219),
    OfflineCity(name: 'خان شيخون، إدلب', lat: 35.4439, lng: 36.6508),
    OfflineCity(name: 'دمشق، سوريا', lat: 33.5138, lng: 36.2765),
    OfflineCity(name: 'دوما، ريف دمشق', lat: 33.5714, lng: 36.4019),
    OfflineCity(name: 'داريا، ريف دمشق', lat: 33.4589, lng: 36.2369),
    OfflineCity(name: 'حمص، سوريا', lat: 34.7324, lng: 36.7137),
    OfflineCity(name: 'الرستن، حمص', lat: 34.9267, lng: 36.7328),
    OfflineCity(name: 'القصير، حمص', lat: 34.5092, lng: 36.5297),
    OfflineCity(name: 'تدمر، حمص', lat: 34.5600, lng: 38.2842),
    OfflineCity(name: 'حماة، سوريا', lat: 35.1318, lng: 36.7578),
    OfflineCity(name: 'سلمية، حماة', lat: 35.0117, lng: 37.0522),
    OfflineCity(name: 'مصياف، حماة', lat: 35.0650, lng: 36.3417),
    OfflineCity(name: 'اللاذقية، سوريا', lat: 35.5317, lng: 35.7917),
    OfflineCity(name: 'جبلة، اللاذقية', lat: 35.3614, lng: 35.9264),
    OfflineCity(name: 'القرداحة، اللاذقية', lat: 35.4578, lng: 36.0617),
    OfflineCity(name: 'طرطوس، سوريا', lat: 34.8890, lng: 35.8866),
    OfflineCity(name: 'بانياس، طرطوس', lat: 35.1814, lng: 35.9419),
    OfflineCity(name: 'صافيتا، طرطوس', lat: 34.8211, lng: 36.1172),
    OfflineCity(name: 'الرقة، سوريا', lat: 35.9525, lng: 39.0089),
    OfflineCity(name: 'تل أبيض، الرقة', lat: 36.6975, lng: 38.9567),
    OfflineCity(name: 'الثورة / الطبقة، الرقة', lat: 35.8367, lng: 38.5436),
    OfflineCity(name: 'دير الزور، سوريا', lat: 35.3359, lng: 40.1408),
    OfflineCity(name: 'الميادين، دير الزور', lat: 34.9983, lng: 40.4533),
    OfflineCity(name: 'البوكمال، دير الزور', lat: 34.4533, lng: 40.9167),
    OfflineCity(name: 'الحسكة، سوريا', lat: 36.5050, lng: 40.7422),
    OfflineCity(name: 'القامشلي، الحسكة', lat: 37.0500, lng: 41.2294),
    OfflineCity(name: 'عامودا، الحسكة', lat: 37.0864, lng: 40.9172),
    OfflineCity(name: 'رأس العين، الحسكة', lat: 36.8500, lng: 40.0667),
    OfflineCity(name: 'المالكية، الحسكة', lat: 37.1772, lng: 42.1389),
    OfflineCity(name: 'درعا، سوريا', lat: 32.6186, lng: 36.1042),
    OfflineCity(name: 'نوى، درعا', lat: 32.8906, lng: 36.0728),
    OfflineCity(name: 'الصنمين، درعا', lat: 33.0694, lng: 36.1836),
    OfflineCity(name: 'السويداء، سوريا', lat: 32.7090, lng: 36.5694),
    OfflineCity(name: 'شهبا، السويداء', lat: 32.8550, lng: 36.6264),
    OfflineCity(name: 'صلخد، السويداء', lat: 32.4939, lng: 36.7117),
    OfflineCity(name: 'القنيطرة، سوريا', lat: 33.1264, lng: 35.8244),

    // Neighboring Border Cities (Turkey, Lebanon, Jordan, Iraq)
    OfflineCity(name: 'كلس، تركيا', lat: 36.7164, lng: 37.1150),
    OfflineCity(name: 'غازي عنتاب، تركيا', lat: 37.0662, lng: 37.3833),
    OfflineCity(name: 'أنطاكيا، تركيا', lat: 36.2022, lng: 36.1603),
    OfflineCity(name: 'الريحانية، تركيا', lat: 36.2683, lng: 36.5700),
    OfflineCity(name: 'أورفا، تركيا', lat: 37.1674, lng: 38.7934),
    OfflineCity(name: 'بيروت، لبنان', lat: 33.8938, lng: 35.5018),
    OfflineCity(name: 'طرابلس، لبنان', lat: 34.4367, lng: 35.8497),
    OfflineCity(name: 'صيدا، لبنان', lat: 33.5631, lng: 35.3689),
    OfflineCity(name: 'عمان، الأردن', lat: 31.9539, lng: 35.9106),
    OfflineCity(name: 'إربد، الأردن', lat: 32.5568, lng: 35.8479),
    OfflineCity(name: 'الرمثا، الأردن', lat: 32.5583, lng: 36.0078),
    OfflineCity(name: 'الموصل، العراق', lat: 36.3350, lng: 43.1189),
    OfflineCity(name: 'بغداد، العراق', lat: 33.3152, lng: 44.3661),

    // Islamic & Arab Capitals / Major Cities
    OfflineCity(name: 'مكة المكرمة، السعودية', lat: 21.4225, lng: 39.8262),
    OfflineCity(name: 'المدينة المنورة، السعودية', lat: 24.4672, lng: 39.6111),
    OfflineCity(name: 'الرياض، السعودية', lat: 24.7136, lng: 46.6753),
    OfflineCity(name: 'جدة، السعودية', lat: 21.5433, lng: 39.1728),
    OfflineCity(name: 'القدس الشريف', lat: 31.7683, lng: 35.2137),
    OfflineCity(name: 'غزة، فلسطين', lat: 31.5017, lng: 34.4668),
    OfflineCity(name: 'القاهرة، مصر', lat: 30.0444, lng: 31.2357),
    OfflineCity(name: 'الإسكندرية، مصر', lat: 31.2001, lng: 29.9187),
    OfflineCity(name: 'الكويت', lat: 29.3759, lng: 47.9774),
    OfflineCity(name: 'الدوحة، قطر', lat: 25.2854, lng: 51.5310),
    OfflineCity(name: 'المنامة، البحرين', lat: 26.2285, lng: 50.5860),
    OfflineCity(name: 'أبوظبي، الإمارات', lat: 24.4539, lng: 54.3773),
    OfflineCity(name: 'دبي، الإمارات', lat: 25.2048, lng: 55.2708),
    OfflineCity(name: 'مسقط، عمان', lat: 23.5880, lng: 58.3829),
    OfflineCity(name: 'صنعاء، اليمن', lat: 15.3694, lng: 44.1910),
    OfflineCity(name: 'طرابلس، ليبيا', lat: 32.8872, lng: 13.1913),
    OfflineCity(name: 'تونس', lat: 36.8065, lng: 10.1815),
    OfflineCity(name: 'الجزائر', lat: 36.7538, lng: 3.0588),
    OfflineCity(name: 'الرباط، المغرب', lat: 34.0209, lng: -6.8416),
  ];

  /// Finds the closest city within [maxDistanceKm] (default 65 km).
  /// Returns null if no city is close enough.
  static String? findNearestCity(double latitude, double longitude, {double maxDistanceKm = 65.0}) {
    OfflineCity? closest;
    double minDistance = double.infinity;

    for (final city in _cities) {
      final d = _haversineDistanceKm(latitude, longitude, city.lat, city.lng);
      if (d < minDistance) {
        minDistance = d;
        closest = city;
      }
    }

    if (closest != null && minDistance <= maxDistanceKm) {
      return closest.name;
    }
    return null;
  }

  static double _haversineDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371.0;
    final double dLat = (lat2 - lat1) * math.pi / 180.0;
    final double dLon = (lon2 - lon1) * math.pi / 180.0;
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180.0) *
            math.cos(lat2 * math.pi / 180.0) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }
}
