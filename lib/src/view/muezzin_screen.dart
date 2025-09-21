// ignore_for_file: unused_element
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muezzin_flutter/core/theme/muezzin_theme.dart';
import 'package:muezzin_flutter/core/utils/extensions.dart';
import 'package:muezzin_flutter/src/logic/muezzin/muezzin_bloc.dart';
import 'package:muezzin_flutter/src/logic/muezzin/muezzin_state.dart';

class MuezzinScreen extends StatefulWidget {
  const MuezzinScreen({super.key});

  @override
  State<MuezzinScreen> createState() => _MuezzinScreenState();
}

class _MuezzinScreenState extends State<MuezzinScreen> {
  MuezzinBloc bloc = MuezzinBloc();
  @override
  void initState() {
    super.initState();
    bloc.add(LoadMuezzin());
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MuezzinBloc, MuezzinState>(
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
                child: _PrayerTimesContent(state: state),
              ),
            ),
            bottomNavigationBar: const _BottomActionsBar(),
          ),
        );
      },
    );
  }
}

// ======================== Prayer Times UI ========================
class _PrayerTimesContent extends StatelessWidget {
  final MuezzinState state;
  const _PrayerTimesContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_HeaderCard(state: state)],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final MuezzinState state;
  const _HeaderCard({required this.state});

  @override
  Widget build(BuildContext context) {
    // We compute the clock here to ensure fresh time per build
    final now = DateTime.now();
    final clock = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
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
      return 'متبقي: $hours:$minutes';
    }

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
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
              _RoundIcon(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.pop(context)),
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
          // Big digital clock
          Text(
            clock,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: MuezzinTheme.onPrimary,
              fontSize: 46,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
              height: 1.0,
            ),
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
        child: Icon(icon, color: MuezzinTheme.onPrimary),
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
            color: MuezzinTheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(width: 6),
        Icon(Icons.alarm, color: MuezzinTheme.onPrimary, size: 18),
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
          Icon(icon, color: MuezzinTheme.onPrimary, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: MuezzinTheme.onPrimary,
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
          Icon(icon, color: MuezzinTheme.onPrimary, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: MuezzinTheme.onPrimary,
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
        border:isNext ? Border.all(width: 1.5, color: MuezzinTheme.goldColor.withValues(alpha: 0.5)) : null,
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
                child: Icon(icon, color: MuezzinTheme.onPrimary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: MuezzinTheme.onPrimary,
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
              color: MuezzinTheme.onPrimary,
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
    Widget item(IconData icon, String label) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: MuezzinTheme.onPrimary.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: MuezzinTheme.onPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: MuezzinTheme.onPrimary, fontSize: 12),
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
            item(Icons.explore_outlined, 'القبلة'),
            item(Icons.timer_outlined, 'العد التنازلي'),
            item(Icons.place_outlined, 'الموقع'),
          ],
        ),
      ),
    );
  }
}


// Combines the card and the repeat bar with a slight overlap like the screenshot
class _CardWithRepeat extends StatelessWidget {
  final String text;
  final int count;
  final int max;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onReset;
  const _CardWithRepeat({
    required this.text,
    required this.count,
    required this.max,
    required this.onMinus,
    required this.onPlus,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DhikrCard(text: text),
        const SizedBox(height: 8),
        _RepeatBar(
          count: count,
          max: max,
          onMinus: onMinus,
          onPlus: onPlus,
          onReset: onReset,
        ),
      ],
    );
  }
}

class _DhikrCard extends StatelessWidget {
  final String text;
  const _DhikrCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final cardColor = Colors.white;
    return PhysicalModel(
      color: cardColor,
      elevation: 6,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          color: cardColor,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              height: 1.7,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _RepeatBar extends StatelessWidget {
  final int count;
  final int max;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onReset;
  const _RepeatBar({
    required this.count,
    required this.max,
    required this.onMinus,
    required this.onPlus,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = Colors.white;
    return PhysicalModel(
      color: barColor,
      elevation: 3,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: barColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'التكرار',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
                const SizedBox(width: 8),
                _MiniCounter(count: count, onMinus: onMinus, onPlus: onPlus),
              ],
            ),
            _ResetButton(onReset: onReset),
          ],
        ),
      ),
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onReset,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 36,
            height: 32,
            child: Icon(Icons.refresh, size: 18),
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 6,
        backgroundColor: Colors.black.withOpacity(0.06),
      ),
    );
  }
}

// Mini counter chip: [-  count  +]
class _MiniCounter extends StatelessWidget {
  final int count;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  const _MiniCounter({
    required this.count,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CapsuleButton(icon: Icons.add, onTap: onPlus),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          _CapsuleButton(icon: Icons.remove, onTap: onMinus),
        ],
      ),
    );
  }
}

class _CapsuleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CapsuleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(width: 36, height: 32, child: Icon(icon, size: 18)),
      ),
    );
  }
}
