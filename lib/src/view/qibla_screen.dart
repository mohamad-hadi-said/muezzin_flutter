import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:muezzin_flutter/core/cache/app_cache.dart';
import 'package:muezzin_flutter/core/theme/muezzin_theme.dart';
import 'package:muezzin_flutter/core/utils/location_helper.dart';
import 'package:muezzin_flutter/core/utils/qibla_calculator.dart';
import 'package:muezzin_flutter/src/view/widgets/qibla_compass_painter.dart';

class QiblaScreen extends StatefulWidget {
  final bool isEmbedded;
  const QiblaScreen({super.key, this.isEmbedded = false});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<CompassEvent>? _compassSubscription;
  late AnimationController _pulseController;

  double _userLat = 36.478616;
  double _userLng = 37.100935;
  String _locationName = 'الموقع الحالي';
  bool _isLoadingLocation = false;
  bool _hasCompassSensor = true;

  double _qiblaBearing = 0.0;
  double _distanceKm = 0.0;

  double _currentHeading = 0.0;
  double _unwrappedHeading = 0.0;
  bool _wasFacingQibla = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _loadUserLocation();
    _initCompass();
  }

  void _loadUserLocation() {
    final cached = AppCache.instance.getUserLocation();
    if (cached != null) {
      _userLat = cached.latitude;
      _userLng = cached.longitude;
    }
    _locationName = LocationHelper.getCachedCityName();
    _recalculateQibla();
  }

  void _recalculateQibla() {
    setState(() {
      _qiblaBearing = QiblaCalculator.calculateQiblaBearing(_userLat, _userLng);
      _distanceKm = QiblaCalculator.calculateDistanceToKaabaKm(_userLat, _userLng);
    });
  }

  Future<void> _refreshGPSLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 8),
          ),
        );
        _userLat = pos.latitude;
        _userLng = pos.longitude;
        final city = await LocationHelper.resolveAndSaveCityName(pos.latitude, pos.longitude);
        _locationName = city;
        _recalculateQibla();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تحديث الموقع: $city', textAlign: TextAlign.center),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('يرجى تفعيل إذن الموقع للحصول على موقع دقيق', textAlign: TextAlign.center),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error getting GPS location: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  void _initCompass() {
    try {
      final stream = FlutterCompass.events;
      if (stream == null) {
        setState(() => _hasCompassSensor = false);
        return;
      }

      _compassSubscription = stream.listen(
        (CompassEvent event) {
          if (event.heading == null) return;

          final rawHeading = event.heading!;
          final normalizedRaw = (rawHeading % 360.0 + 360.0) % 360.0;

          // Smooth unwrap to avoid sudden 360-degree spins
          double diff = (normalizedRaw - (_unwrappedHeading % 360.0)) % 360.0;
          if (diff > 180.0) diff -= 360.0;
          if (diff < -180.0) diff += 360.0;

          final newUnwrapped = _unwrappedHeading + diff;
          final isFacing = QiblaCalculator.isFacingQibla(normalizedRaw, _qiblaBearing);

          if (isFacing && !_wasFacingQibla) {
            HapticFeedback.mediumImpact();
          }
          _wasFacingQibla = isFacing;

          if (mounted) {
            setState(() {
              _currentHeading = normalizedRaw;
              _unwrappedHeading = newUnwrapped;
            });
          }
        },
        onError: (e) {
          debugPrint('Compass stream error: $e');
          if (mounted) {
            setState(() => _hasCompassSensor = false);
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('Error initializing compass: $e');
      if (mounted) {
        setState(() => _hasCompassSensor = false);
      }
    }
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _showCalibrationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: MuezzinTheme.primaryColor),
            SizedBox(width: 8),
            Text('معايرة البوصلة', style: TextStyle(fontFamily: 'Cairo', fontSize: 18)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'للحصول على أعلى دقة في تحديد اتجاه القبلة:',
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '1. احرص على إبعاد الهاتف عن أي أجهزة إلكترونية أو أسطح معدنية أو مغناطيسية.',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
            ),
            SizedBox(height: 6),
            Text(
              '2. أمسك الهاتف بشكل أفقي مستوٍ في راحة يدك.',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
            ),
            SizedBox(height: 6),
            Text(
              '3. حرّك الهاتف في الهواء على شكل رقم 8 بالإنجليزية (∞) عدة مرات لمعايرة مستشعر المغناطيسية.',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final compassDiameter = math.min(size.width * 0.78, 320.0);
    final isAligned = QiblaCalculator.isFacingQibla(_currentHeading, _qiblaBearing);
    final angleDiff = QiblaCalculator.getAngleDifference(_currentHeading, _qiblaBearing);

    final content = SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [MuezzinTheme.gradientTop, MuezzinTheme.gradientBottom],
          ),
        ),
        child: SafeArea(
          top: !widget.isEmbedded,
          bottom: false,
          child: Column(
            children: [
              // Top Bar
              _buildTopBar(context),
      
              // Content Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      // Location & Kaaba Distance Card
                      _buildInfoCard(),
                      const SizedBox(height: 16),
      
                      // Status Alignment Banner
                      _buildStatusBanner(isAligned, angleDiff),
                      const SizedBox(height: 24),
      
                      // Compass Display Widget
                      _buildCompassSection(compassDiameter, isAligned),
                      const SizedBox(height: 24),
      
                      // Orientation Numbers Card
                      _buildAngleMetricsCard(angleDiff),
                      const SizedBox(height: 16),
      
                      // Calibration Tip Button
                      _buildCalibrationTipCard(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.isEmbedded) {
      return content;
    }

    return Scaffold(
      body: content,
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!widget.isEmbedded)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: MuezzinTheme.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            )
          else
            IconButton(
              icon: const Icon(Icons.help_outline_rounded, color: MuezzinTheme.textPrimary),
              tooltip: 'معايرة البوصلة',
              onPressed: _showCalibrationDialog,
            ),
          const Row(
            children: [
              Icon(Icons.explore_rounded, color: MuezzinTheme.textPrimary, size: 24),
              SizedBox(width: 8),
              Text(
                'اتجاه القبلة',
                style: TextStyle(
                  color: MuezzinTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          IconButton(
            icon: _isLoadingLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: MuezzinTheme.textPrimary),
                  )
                : const Icon(Icons.my_location_rounded, color: MuezzinTheme.textPrimary),
            tooltip: 'تحديث الموقع عبر GPS',
            onPressed: _isLoadingLocation ? null : _refreshGPSLocation,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: MuezzinTheme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Qibla Angle
          Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.navigation_rounded, size: 16, color: MuezzinTheme.primaryColor),
                  SizedBox(width: 4),
                  Text('زاوية القبلة', style: TextStyle(color: MuezzinTheme.textSecondary, fontSize: 12, fontFamily: 'Cairo')),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${_qiblaBearing.round()}°',
                style: const TextStyle(
                  color: MuezzinTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          Container(height: 36, width: 1, color: MuezzinTheme.outlineColor),

          // Distance to Kaaba
          Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.place_rounded, size: 16, color: MuezzinTheme.goldColor),
                  SizedBox(width: 4),
                  Text('المسافة لمكة', style: TextStyle(color: MuezzinTheme.textSecondary, fontSize: 12, fontFamily: 'Cairo')),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${_distanceKm.round()} كم',
                style: const TextStyle(
                  color: MuezzinTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          Container(height: 36, width: 1, color: MuezzinTheme.outlineColor),

          // Location
          Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.location_city_rounded, size: 16, color: MuezzinTheme.primaryColor),
                  SizedBox(width: 4),
                  Text('الموقع', style: TextStyle(color: MuezzinTheme.textSecondary, fontSize: 12, fontFamily: 'Cairo')),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _locationName,
                style: const TextStyle(
                  color: MuezzinTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(bool isAligned, double angleDiff) {
    if (isAligned) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: MuezzinTheme.successColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MuezzinTheme.successColor, width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: MuezzinTheme.successColor, size: 24),
            SizedBox(width: 10),
            Text(
              'أنت الآن باتجاه القبلة الشريفة 🕋',
              style: TextStyle(
                color: MuezzinTheme.successColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      );
    }

    final isTurnRight = angleDiff > 0;
    final diffDegrees = angleDiff.abs().round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: MuezzinTheme.cardColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MuezzinTheme.outlineColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isTurnRight ? Icons.rotate_right_rounded : Icons.rotate_left_rounded,
            color: MuezzinTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'أدر الهاتف ${isTurnRight ? 'يميناً' : 'يساراً'} بمقدار $diffDegrees°',
            style: const TextStyle(
              color: MuezzinTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassSection(double diameter, bool isAligned) {
    if (!_hasCompassSensor) {
      return Container(
        height: diameter,
        width: diameter,
        decoration: BoxDecoration(
          color: MuezzinTheme.cardColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.screen_rotation_rounded, size: 48, color: MuezzinTheme.textSecondary),
            const SizedBox(height: 12),
            const Text(
              'مستشعر البوصلة غير متوفر',
              style: TextStyle(color: MuezzinTheme.textPrimary, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 6),
            Text(
              'زاوية القبلة من الشمال: ${_qiblaBearing.round()}°',
              style: const TextStyle(color: MuezzinTheme.primaryColor, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: _unwrappedHeading),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          builder: (context, animatedHeading, child) {
            final rotationRad = -animatedHeading * (math.pi / 180.0);

            return Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isAligned
                        ? MuezzinTheme.successColor.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.1),
                    blurRadius: isAligned ? 25 : 15,
                    spreadRadius: isAligned ? 4 : 1,
                  ),
                ],
              ),
              child: Transform.rotate(
                angle: rotationRad,
                child: CustomPaint(
                  size: Size(diameter, diameter),
                  painter: QiblaCompassPainter(
                    qiblaBearing: _qiblaBearing,
                    isAligned: isAligned,
                    pulseValue: _pulseController.value,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAngleMetricsCard(double angleDiff) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: MuezzinTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem('اتجاه الهاتف', '${_currentHeading.round()}°'),
          Container(height: 28, width: 1, color: MuezzinTheme.outlineColor),
          _buildMetricItem('زاوية القبلة', '${_qiblaBearing.round()}°'),
          Container(height: 28, width: 1, color: MuezzinTheme.outlineColor),
          _buildMetricItem('فارق الزاوية', '${angleDiff.abs().round()}°'),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: MuezzinTheme.textSecondary, fontSize: 11, fontFamily: 'Cairo')),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: MuezzinTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  Widget _buildCalibrationTipCard() {
    return InkWell(
      onTap: _showCalibrationDialog,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: MuezzinTheme.cardColor.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: MuezzinTheme.outlineColor.withValues(alpha: 0.6)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: MuezzinTheme.primaryColor, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'كيفية معايرة البوصلة لضمان الدقة العالية',
                style: TextStyle(
                  color: MuezzinTheme.textPrimary,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: MuezzinTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
