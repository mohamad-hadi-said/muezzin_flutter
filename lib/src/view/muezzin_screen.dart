import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muezzin_flutter/core/cache/app_cache.dart';
import 'package:muezzin_flutter/core/theme/muezzin_theme.dart';
import 'package:muezzin_flutter/core/utils/extensions.dart';
import 'package:muezzin_flutter/core/utils/location_helper.dart';
import 'package:muezzin_flutter/src/logic/muezzin/muezzin_bloc.dart';
import 'package:muezzin_flutter/src/logic/muezzin/muezzin_state.dart';
import 'package:muezzin_flutter/src/view/qibla_screen.dart';
import 'package:muezzin_flutter/src/view/settings_screen.dart';
import 'package:muezzin_flutter/src/view/widgets/get_current_location.dart';
import 'package:muezzin_flutter/src/view/widgets/liquid_glass.dart';

class MuezzinScreen extends StatefulWidget {
  const MuezzinScreen({super.key});

  @override
  State<MuezzinScreen> createState() => _MuezzinScreenState();
}

class _MuezzinScreenState extends State<MuezzinScreen> {
  final MuezzinBloc _bloc = MuezzinBloc();
  final ValueNotifier<DateTime> _now = ValueNotifier<DateTime>(DateTime.now());
  Timer? _clockTimer;
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _selectUserLocation() async {
    final userLocation = AppCache.instance.getUserLocation();
    if (userLocation != null) {
      return;
    }

    final result = await showDialog<bool?>(
      context: context,
      builder: (context) => const GetCurrentLocation(),
    );
    if (result == true) {
      _bloc.add(LoadMuezzin());
    }
  }

  @override
  void initState() {
    super.initState();
    _bloc.add(LoadMuezzin());
    if (AppCache.instance.getUserLocation() == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _selectUserLocation();
      });
    }
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _now.value = DateTime.now();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _now.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<MuezzinBloc, MuezzinState>(
        bloc: _bloc,
        builder: (context, state) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              extendBody: true,
              body: LiquidBackground(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    _PrayerTimesContent(
                      state: state,
                      nowListenable: _now,
                      onRefreshLocation: () {
                        _bloc.add(LoadMuezzin());
                        setState(() {});
                      },
                    ),
                    const QiblaScreen(isEmbedded: true),
                    SettingsScreen(
                      isEmbedded: true,
                      onSettingsChanged: () {
                        _bloc.add(LoadMuezzin());
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: _FloatingLiquidGlassNavBar(
                selectedIndex: _selectedIndex,
                onTabSelected: _onTabSelected,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ======================== Liquid Glass Prayer Times UI ========================

class _PrayerTimesContent extends StatelessWidget {
  final MuezzinState state;
  final ValueListenable<DateTime> nowListenable;
  final VoidCallback onRefreshLocation;

  const _PrayerTimesContent({
    required this.state,
    required this.nowListenable,
    required this.onRefreshLocation,
  });

  @override
  Widget build(BuildContext context) {
    if (state.loading && state.prayerTimes == null) {
      return Center(
        child: LiquidGlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          borderRadius: BorderRadius.circular(24),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: MuezzinTheme.textPrimary,
                strokeWidth: 2.5,
              ),
              SizedBox(height: 16),
              Text(
                'جاري تحميل مواقيت الصلاة...',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: MuezzinTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final timings = state.prayerTimes?.timings;
    bool isNext(String key) => state.nextPrayerKey == key;

    String formatTime(String? iso) {
      if (iso == null) return '--:--';
      try {
        return iso.fromIsoTime();
      } catch (_) {
        return iso;
      }
    }

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Top Liquid Glass Bar
            _TopGlassBar(onLocationUpdated: onRefreshLocation),
            const SizedBox(height: 14),

            // 2. Centerpiece Hero Liquid Glass Card (Clock & Next Prayer)
            _HeroPrayerClockCard(state: state, nowListenable: nowListenable),
            const SizedBox(height: 22),

            // 3. Section Title with Liquid Accent
            _buildSectionHeader(),
            const SizedBox(height: 12),

            // 4. Liquid Glass Prayer Cards
            _LiquidPrayerTile(
              name: 'الفجر',
              timeText: formatTime(timings?.fajr),
              isNext: isNext('fajr'),
              icon: Icons.wb_twilight_rounded,
            ),
            const SizedBox(height: 10),
            _LiquidPrayerTile(
              name: 'الشروق',
              timeText: formatTime(timings?.sunrise),
              isNext: isNext('sunrise'),
              icon: Icons.wb_sunny_rounded,
            ),
            const SizedBox(height: 10),
            _LiquidPrayerTile(
              name: 'الظهر',
              timeText: formatTime(timings?.dhuhr),
              isNext: isNext('dhuhr'),
              icon: Icons.light_mode_rounded,
            ),
            const SizedBox(height: 10),
            _LiquidPrayerTile(
              name: 'العصر',
              timeText: formatTime(timings?.asr),
              isNext: isNext('asr'),
              icon: Icons.brightness_medium_rounded,
            ),
            const SizedBox(height: 10),
            _LiquidPrayerTile(
              name: 'المغرب',
              timeText: formatTime(timings?.maghrib ?? timings?.sunset),
              isNext: isNext('maghrib'),
              icon: Icons.nightlight_rounded,
            ),
            const SizedBox(height: 10),
            _LiquidPrayerTile(
              name: 'العشاء',
              timeText: formatTime(timings?.isha),
              isNext: isNext('isha'),
              icon: Icons.nights_stay_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: MuezzinTheme.goldColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'مواقيت صلاة اليوم',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: MuezzinTheme.textPrimary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 0.8,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 14,
                  color: MuezzinTheme.goldColor,
                ),
                SizedBox(width: 4),
                Text(
                  'أوقات دقيقة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: MuezzinTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================== Top Liquid Glass Bar ========================

class _TopGlassBar extends StatelessWidget {
  final VoidCallback onLocationUpdated;

  const _TopGlassBar({required this.onLocationUpdated});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Location Selector Liquid Pill
        Expanded(
          child: LiquidGlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            borderRadius: BorderRadius.circular(20),
            blur: 16,
            onTap: () async {
              final result = await showDialog<bool?>(
                context: context,
                builder: (context) => const GetCurrentLocation(),
              );
              if (result == true) {
                onLocationUpdated();
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: MuezzinTheme.goldColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: MuezzinTheme.goldColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'الموقع الحالي',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: MuezzinTheme.textSecondary,
                        ),
                      ),
                      Text(
                        LocationHelper.getCachedCityName(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: MuezzinTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: MuezzinTheme.textSecondary.withValues(alpha: 0.8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Quick GPS Update Action Button
        LiquidGlassContainer(
          padding: const EdgeInsets.all(10),
          borderRadius: BorderRadius.circular(18),
          blur: 16,
          onTap: () async {
            final result = await showDialog<bool?>(
              context: context,
              builder: (context) => const GetCurrentLocation(),
            );
            if (result == true) {
              onLocationUpdated();
            }
          },
          child: const Icon(
            Icons.my_location_rounded,
            color: MuezzinTheme.textPrimary,
            size: 20,
          ),
        ),
      ],
    );
  }
}

// ======================== Hero Liquid Glass Card ========================

class _HeroPrayerClockCard extends StatelessWidget {
  final MuezzinState state;
  final ValueListenable<DateTime> nowListenable;

  const _HeroPrayerClockCard({
    required this.state,
    required this.nowListenable,
  });

  String _arabicPrayerName(String? key) {
    if (key == null) return '';
    switch (key.toLowerCase()) {
      case 'fajr':
        return 'الفجر';
      case 'sunrise':
        return 'الشروق';
      case 'dhuhr':
        return 'الظهر';
      case 'asr':
        return 'العصر';
      case 'maghrib':
        return 'المغرب';
      case 'isha':
        return 'العشاء';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextPrayerKey = state.nextPrayerKey;
    final nextName = _arabicPrayerName(nextPrayerKey);
    final date = state.prayerTimes?.date;

    return LiquidGlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      borderRadius: BorderRadius.circular(30),
      blur: 22,
      gradientColors: [
        Colors.white.withValues(alpha: 0.50),
        Colors.white.withValues(alpha: 0.22),
      ],
      borderWidth: 1.2,
      borderColor: Colors.white.withValues(alpha: 0.65),
      child: Column(
        children: [
          // Next Prayer Floating Pill with Live Countdown
          if (nextPrayerKey != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    MuezzinTheme.goldColor.withValues(alpha: 0.28),
                    Colors.white.withValues(alpha: 0.35),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: MuezzinTheme.goldColor.withValues(alpha: 0.6),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: MuezzinTheme.goldColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: MuezzinTheme.goldColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'الصلاة القادمة: صلاة $nextName',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: MuezzinTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: MuezzinTheme.textPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ValueListenableBuilder<DateTime>(
                      valueListenable: nowListenable,
                      builder: (context, now, _) {
                        final nextTime = state.nextPrayerTime;
                        if (nextTime == null) return const SizedBox.shrink();
                        final diff = nextTime.difference(now);
                        if (diff.isNegative) return const SizedBox.shrink();

                        final h = diff.inHours.toString().padLeft(2, '0');
                        final m = (diff.inMinutes % 60).toString().padLeft(
                          2,
                          '0',
                        );
                        final s = (diff.inSeconds % 60).toString().padLeft(
                          2,
                          '0',
                        );
                        return Text(
                          'بعد $h:$m:$s',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: MuezzinTheme.goldColor,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          // Big Crisp Glass Clock
          ValueListenableBuilder<DateTime>(
            valueListenable: nowListenable,
            builder: (context, now, _) {
              final clock =
                  '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
              return Text(
                clock,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: MuezzinTheme.textPrimary,
                  fontSize: 50,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  height: 1.0,
                  shadows: [
                    Shadow(
                      color: Color(0x20000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Date Chips in Frosted Glass Capsules
          Row(
            children: [
              Expanded(
                child: _GlassDateCapsule(
                  icon: Icons.calendar_month_rounded,
                  text: date?.readable ?? '—',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GlassDateCapsule(
                  icon: Icons.nightlight_round,
                  text: date?.hijri != null
                      ? '${date!.hijri!.day ?? ''} ${date.hijri!.month?.ar ?? ''} ${date.hijri!.year ?? ''} هـ'
                      : '—',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassDateCapsule extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GlassDateCapsule({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 0.9,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: MuezzinTheme.goldColor, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: MuezzinTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================== Liquid Glass Prayer Tile ========================

class _LiquidPrayerTile extends StatelessWidget {
  final String name;
  final String timeText;
  final IconData icon;
  final bool isNext;

  const _LiquidPrayerTile({
    required this.name,
    required this.timeText,
    required this.icon,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: BorderRadius.circular(22),
      blur: 16,
      isGlowing: isNext,
      glowColor: MuezzinTheme.goldColor,
      borderWidth: isNext ? 1.6 : 1.0,
      borderColor: isNext
          ? MuezzinTheme.goldColor.withValues(alpha: 0.85)
          : Colors.white.withValues(alpha: 0.50),
      gradientColors: isNext
          ? [
              MuezzinTheme.goldColor.withValues(alpha: 0.24),
              Colors.white.withValues(alpha: 0.42),
            ]
          : [
              Colors.white.withValues(alpha: 0.36),
              Colors.white.withValues(alpha: 0.15),
            ],
      child: Row(
        children: [
          // Prayer Icon with Fluid Glass Background
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isNext
                    ? [
                        MuezzinTheme.goldColor.withValues(alpha: 0.35),
                        MuezzinTheme.goldColor.withValues(alpha: 0.15),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.45),
                        Colors.white.withValues(alpha: 0.15),
                      ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isNext
                    ? MuezzinTheme.goldColor.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: isNext
                  ? MuezzinTheme.goldColor
                  : MuezzinTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Prayer Title & Upcoming Badge
          Expanded(
            child: Row(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: MuezzinTheme.textPrimary,
                    fontWeight: isNext ? FontWeight.w900 : FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                if (isNext) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: MuezzinTheme.goldColor.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: MuezzinTheme.goldColor.withValues(alpha: 0.5),
                        width: 0.8,
                      ),
                    ),
                    child: const Text(
                      'القادمة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: MuezzinTheme.goldColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Prayer Time with Refined Glass Look
          Text(
            timeText,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: isNext
                  ? MuezzinTheme.textPrimary
                  : MuezzinTheme.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================== Floating Liquid Glass Bottom Navigation Bar ========================

class _FloatingLiquidGlassNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const _FloatingLiquidGlassNavBar({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    Widget navItem({
      required int index,
      required IconData icon,
      required IconData activeIcon,
      required String label,
    }) {
      final bool isActive = selectedIndex == index;
      return Expanded(
        child: InkWell(
          onTap: () => onTabSelected(index),
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? MuezzinTheme.goldColor.withValues(alpha: 0.22)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              border: isActive
                  ? Border.all(
                      color: MuezzinTheme.goldColor.withValues(alpha: 0.55),
                      width: 1.2,
                    )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive
                      ? MuezzinTheme.goldColor
                      : MuezzinTheme.textSecondary,
                  size: 24,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: isActive
                        ? MuezzinTheme.goldColor
                        : MuezzinTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F355C).withValues(alpha: 0.16),
              blurRadius: 28,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: -1,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.45),
                    Colors.white.withValues(alpha: 0.20),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.65),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  navItem(
                    index: 0,
                    icon: Icons.access_time_rounded,
                    activeIcon: Icons.access_time_filled_rounded,
                    label: 'مواقيت الصلاة',
                  ),
                  navItem(
                    index: 1,
                    icon: Icons.explore_outlined,
                    activeIcon: Icons.explore_rounded,
                    label: 'القبلة',
                  ),
                  navItem(
                    index: 2,
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_rounded,
                    label: 'الإعدادات',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
