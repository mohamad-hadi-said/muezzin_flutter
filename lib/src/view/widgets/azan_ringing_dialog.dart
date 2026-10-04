import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:muezzin_flutter/core/theme/muezzin_theme.dart';

class AzanRingingDialog extends StatefulWidget {
  final AlarmSettings alarmSettings;

  const AzanRingingDialog({
    super.key,
    required this.alarmSettings,
  });

  static Future<void> show(BuildContext context, AlarmSettings settings) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'AzanRinging',
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return AzanRingingDialog(alarmSettings: settings);
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<AzanRingingDialog> createState() => _AzanRingingDialogState();
}

class _AzanRingingDialogState extends State<AzanRingingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _stopAzan() async {
    await Alarm.stop(widget.alarmSettings.id);
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.alarmSettings.notificationSettings.title;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  MuezzinTheme.gradientTop,
                  MuezzinTheme.secondaryColor,
                  MuezzinTheme.gradientBottom,
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: MuezzinTheme.goldColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Mosque/Bell Icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MuezzinTheme.goldColor.withValues(alpha: 0.18),
                      border: Border.all(
                        color: MuezzinTheme.goldColor,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: MuezzinTheme.goldColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mosque_rounded,
                      size: 46,
                      color: MuezzinTheme.goldColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: MuezzinTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                const Text(
                  'حيّ على الصلاة .. حيّ على الفلاح',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: MuezzinTheme.goldColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // Duaa after Azan quote card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: MuezzinTheme.onPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '«اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ القَائِمَةِ، آتِ مُحَمَّداً الوَسِيلَةَ وَالفَضِيلَةَ، وَابْعَثْهُ مَقَاماً مَحْمُوداً الَّذِي وَعَدْتَهُ»',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MuezzinTheme.textSecondary,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Stop Azan Action Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _stopAzan,
                    icon: const Icon(
                      Icons.stop_circle_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                    label: const Text(
                      'إيقاف الأذان',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MuezzinTheme.accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
