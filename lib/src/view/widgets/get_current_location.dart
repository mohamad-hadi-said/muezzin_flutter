import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:muezzin_flutter/core/cache/app_cache.dart';
import 'package:muezzin_flutter/core/theme/muezzin_theme.dart';
import 'package:muezzin_flutter/core/utils/toast.dart';

class GetCurrentLocation extends StatefulWidget {
  const GetCurrentLocation({Key? key}) : super(key: key);

  @override
  State<GetCurrentLocation> createState() => _GetCurrentLocationState();
}

class _GetCurrentLocationState extends State<GetCurrentLocation> {
  bool _loading = false;
  String? _error;
  Position? _position;

  Future<void> _ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        Toast.error(context, 'خدمة الموقع غير مفعلة. الرجاء تفعيل GPS.');
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          Toast.error(context, 'تم رفض إذن الموقع.');
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        Toast.error(
          context,
          'تم رفض إذن الموقع نهائيًا. الرجاء السماح من إعدادات التطبيق.',
        );
      }
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _ensurePermission();
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _position = position;
      });
      await AppCache().saveUserLocation(position);
      await AppCache().saveMonthOfPrayerTimes(-1);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        Toast.error(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lat = _position?.latitude;
    final lon = _position?.longitude;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: PhysicalModel(
          color: Colors.white,
          elevation: 8,
          shadowColor: Colors.black12,
          borderRadius: BorderRadius.circular(22),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [MuezzinTheme.gradientTop, MuezzinTheme.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Container(
                margin: const EdgeInsets.all(1.2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: MuezzinTheme.onPrimary.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.my_location, color: MuezzinTheme.onBackground),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'تحديد موقعي الحالي',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: MuezzinTheme.onBackground,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.close_rounded, color: MuezzinTheme.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'سنستخدم موقعك لتحديد مواقيت الصلاة بدقة حسب منطقتك.',
                      style: const TextStyle(color: MuezzinTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MuezzinTheme.secondaryColor,
                        foregroundColor: MuezzinTheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _loading ? null : _getLocation,
                      icon: const Icon(Icons.location_searching_rounded),
                      label: Text(_loading ? 'جاري التحديد...' : 'الحصول على موقعي'),
                    ),
                    const SizedBox(height: 12),
                    if (_loading) ...[
                      const Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE9E9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFC5C5)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.redAccent),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: Geolocator.openLocationSettings,
                            icon: const Icon(Icons.gps_fixed),
                            label: const Text('إعدادات الموقع'),
                          ),
                          OutlinedButton.icon(
                            onPressed: Geolocator.openAppSettings,
                            icon: const Icon(Icons.app_settings_alt),
                            label: const Text('إعدادات التطبيق'),
                          ),
                        ],
                      ),
                    ],
                    if (lat != null && lon != null) ...[
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: MuezzinTheme.onPrimary.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.place, color: MuezzinTheme.onBackground, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'الموقع: ${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}',
                                style: const TextStyle(color: MuezzinTheme.onBackground, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
