// ignore_for_file: unused_element
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muezzin_flutter/core/cache/app_cache.dart';
import 'package:muezzin_flutter/core/theme/muezzin_theme.dart';
import 'package:muezzin_flutter/core/utils/extensions.dart';
import 'package:muezzin_flutter/src/logic/muezzin/muezzin_bloc.dart';
import 'package:muezzin_flutter/src/logic/muezzin/muezzin_state.dart';
import 'package:muezzin_flutter/src/view/widgets/get_current_location.dart';

class MuezzinScreen extends StatefulWidget {
  const MuezzinScreen({super.key});

  @override
  State<MuezzinScreen> createState() => _MuezzinScreenState();
}

class _MuezzinScreenState extends State<MuezzinScreen> {
  MuezzinBloc bloc = MuezzinBloc();
  final ValueNotifier<DateTime> _now = ValueNotifier<DateTime>(DateTime.now());
  Timer? _clockTimer;

  Future<void> _selectUserLocation() async {
    final userLocation = AppCache.instance.getUserLocation();
    if (userLocation != null) {
      return;
    }

    final result = await showDialog<bool?>(
      context: context,
      builder: (context) => const GetCurrentLocation(),
    );
    if (result != null && result) {
      bloc.add(LoadMuezzin());
    }
  }

  @override
  void initState() {
    super.initState();
    final userLocation = AppCache.instance.getUserLocation();
    if (userLocation != null) {
      bloc.add(LoadMuezzin());
    } else {
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
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => bloc,
      child: BlocBuilder<MuezzinBloc, MuezzinState>(
        bloc: bloc,
        builder: (context, state) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: null,
              body: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      MuezzinTheme.gradientTop,
                      MuezzinTheme.gradientBottom,
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: _PrayerTimesContent(state: state, nowListenable: _now),
                ),
              ),
              bottomNavigationBar: const _BottomActionsBar(),
            ),
          );
        },
      ),
    );
  }
}

// ======================== Prayer Times UI ========================
class _PrayerTimesContent extends StatelessWidget {
  final MuezzinState state;
  final ValueListenable<DateTime> nowListenable;
  const _PrayerTimesContent({required this.state, required this.nowListenable});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_HeaderCard(state: state, nowListenable: nowListenable)],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final MuezzinState state;
  final ValueListenable<DateTime> nowListenable;
  const _HeaderCard({required this.state, required this.nowListenable});

  @override
  Widget build(BuildContext context) {
    final timings = state.prayerTimes?.timings;
    final date = state.prayerTimes?.date;

    bool isNext(String key) => state.nextPrayerKey == key;

    String? remainingTextFor(String key) {
      if (!isNext(key)) return null;
      final d = state.timeUntilNext;
      if (d == null) return null;
      final totalSeconds = d.inSeconds;
      final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
      final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
      return 'بعد $hours ساعة و $minutes دقيقة';
    }

    return Container(
      margin: const EdgeInsets.only(top: 32, bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MuezzinTheme.gradientTop, MuezzinTheme.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _RoundIcon(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
              ),
              Expanded(child: Center(child: _TitleWithIcon())),
              _RoundIcon(icon: Icons.menu_rounded),
            ],
          ),
          /* const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  icon: Icons.location_on_outlined,
                  text: tz.isNotEmpty ? tz : '—',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoChip(
                  icon: Icons.place_outlined,
                  text: '${meta?.latitude?.toStringAsFixed(3) ?? '--'}, ${meta?.longitude?.toStringAsFixed(3) ?? '--'}',
                ),
              ),
            ],
          ), */
          const SizedBox(height: 24),
          // Big digital clock (updates every second via ValueListenable)
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
                  fontSize: 46,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  height: 1.0,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _DateChip(
                  icon: Icons.event_note_outlined,
                  text: date?.readable ?? '—',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateChip(
                  icon: Icons.event_outlined,
                  text: '${date?.hijri?.date ?? '—'} هـ',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Prayer tiles
          _PrayerTile(
            name: 'الفجر',
            timeText: timings?.fajr?.fromIsoTime() ?? '--:--',
            isNext: isNext('fajr'),
            subtitle: remainingTextFor('fajr'),
            icon: Icons.wb_twilight,
          ),
          const SizedBox(height: 12),
          _PrayerTile(
            name: 'الشروق',
            timeText: timings?.sunrise?.fromIsoTime() ?? '--:--',
            isNext: isNext('sunrise'),
            subtitle: remainingTextFor('sunrise'),
            icon: Icons.wb_sunny,
          ),
          const SizedBox(height: 12),
          _PrayerTile(
            name: 'الظهر',
            timeText: timings?.dhuhr?.fromIsoTime() ?? '--:--',
            isNext: isNext('dhuhr'),
            subtitle: remainingTextFor('dhuhr'),
            icon: Icons.wb_sunny_outlined,
          ),
          const SizedBox(height: 12),
          _PrayerTile(
            name: 'العصر',
            timeText: timings?.asr?.fromIsoTime() ?? '--:--',
            isNext: isNext('asr'),
            subtitle: remainingTextFor('asr'),
            icon: Icons.location_city_outlined,
          ),
          const SizedBox(height: 12),
          _PrayerTile(
            name: 'المغرب',
            timeText: timings?.maghrib?.fromIsoTime() ?? '--:--',
            isNext: isNext('maghrib'),
            subtitle: remainingTextFor('maghrib'),
            icon: Icons.nightlight,
          ),
          const SizedBox(height: 12),
          _PrayerTile(
            name: 'العشاء',
            timeText: timings?.isha?.fromIsoTime() ?? '--:--',
            isNext: isNext('isha'),
            subtitle: remainingTextFor('isha'),
            icon: Icons.nightlight_round,
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _RoundIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: MuezzinTheme.onPrimary.withOpacity(0.25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: MuezzinTheme.goldColor),
      ),
    );
  }
}

class _TitleWithIcon extends StatelessWidget {
  const _TitleWithIcon();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text(
          'مواقيت الصلاة',
          style: TextStyle(
            color: MuezzinTheme.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(width: 6),
        Icon(Icons.alarm, color: MuezzinTheme.textSecondary, size: 18),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: MuezzinTheme.onPrimary.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: MuezzinTheme.goldColor, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: MuezzinTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DateChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: MuezzinTheme.onPrimary.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: MuezzinTheme.goldColor, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: MuezzinTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerTile extends StatelessWidget {
  final String name;
  final String timeText; // already Arabic digits
  final IconData icon;
  final bool isNext;
  final String? subtitle;
  const _PrayerTile({
    required this.name,
    required this.timeText,
    required this.icon,
    this.isNext = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: MuezzinTheme.onPrimary.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(18),
        border: isNext
            ? Border.all(
                width: 1.5,
                color: MuezzinTheme.goldColor.withValues(alpha: 0.5),
              )
            : null,
      ),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: MuezzinTheme.onPrimary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: MuezzinTheme.goldColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: MuezzinTheme.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  if (isNext && subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: MuezzinTheme.goldColor.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const Spacer(),
          // Left side: time
          Text(
            timeText,
            style: const TextStyle(
              color: MuezzinTheme.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionsBar extends StatelessWidget {
  const _BottomActionsBar();

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String label, {VoidCallback? onTap}) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: MuezzinTheme.onPrimary.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: MuezzinTheme.goldColor),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: MuezzinTheme.textSecondary, fontSize: 12),
          ),
        ],
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [MuezzinTheme.secondaryColor, MuezzinTheme.gradientBottom],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            item(Icons.explore_outlined, 'القبلة', onTap: () {}),
            item(Icons.timer_outlined, 'العد التنازلي', onTap: () {}),
            item(
              Icons.place_outlined,
              'الموقع',
              onTap: () async {
                final result = await showDialog<bool?>(
                  context: context,
                  builder: (context) => const GetCurrentLocation(),
                );
                if (result != null && result && context.mounted) {
                  context.read<MuezzinBloc>().add(LoadMuezzin());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}