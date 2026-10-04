import 'package:flutter/material.dart';
import 'package:muezzin_flutter/core/cache/app_cache.dart';
import 'package:muezzin_flutter/core/services/prayer_alarm_service.dart';
import 'package:muezzin_flutter/core/theme/muezzin_theme.dart';
import 'package:muezzin_flutter/core/utils/location_helper.dart';
import 'package:muezzin_flutter/src/view/widgets/get_current_location.dart';
import 'package:muezzin_flutter/src/view/widgets/liquid_glass.dart';

class CalculationMethodOption {
  final int id;
  final String title;
  final String description;

  const CalculationMethodOption({
    required this.id,
    required this.title,
    required this.description,
  });
}

const List<CalculationMethodOption> calculationMethods = [
  CalculationMethodOption(
    id: 3,
    title: 'رابطة العالم الإسلامي (MWL)',
    description: 'الفجر 18° والعشاء 17° (شائع الاستخدام عالمياً)',
  ),
  CalculationMethodOption(
    id: 4,
    title: 'جامعة أم القرى - مكة المكرمة',
    description: 'الفجر 18.5° والعشاء بعد 90 دقيقة (المملكة العربية السعودية)',
  ),
  CalculationMethodOption(
    id: 5,
    title: 'الهيئة المصرية العامة للمساحة',
    description: 'الفجر 19.5° والعشاء 17.5° (مصر وأفريقيا وبلاد الشام)',
  ),
  CalculationMethodOption(
    id: 1,
    title: 'جامعة العلوم الإسلامية بكراتشي',
    description: 'الفجر 18° والعشاء 18° (باكستان، الهند، بنغلاديش)',
  ),
  CalculationMethodOption(
    id: 2,
    title: 'الجمعية الإسلامية لأمريكا الشمالية (ISNA)',
    description: 'الفجر 15° والعشاء 15° (شمال أمريكا)',
  ),
  CalculationMethodOption(
    id: 8,
    title: 'منطقة الخليج العربي',
    description: 'طريقة معتمدة في دول مجلس التعاون الخليجي',
  ),
  CalculationMethodOption(
    id: 9,
    title: 'وزارة الأوقاف - دولة الكويت',
    description: 'الفجر 18° والعشاء 17.5°',
  ),
  CalculationMethodOption(
    id: 10,
    title: 'وزارة الأوقاف - دولة قطر',
    description: 'الفجر 18° والعشاء بعد 90 دقيقة',
  ),
  CalculationMethodOption(
    id: 13,
    title: 'رئاسة الشؤون الدينية (ديانت) - تركيا',
    description: 'المعتمدة في تركيا والمجتمعات التركية بأوروبا',
  ),
  CalculationMethodOption(
    id: 12,
    title: 'اتحاد المنظمات الإسلامية في فرنسا (UOIF)',
    description: 'الفجر 12° والعشاء 12°',
  ),
];

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onSettingsChanged;
  final bool isEmbedded;

  const SettingsScreen({
    super.key,
    this.onSettingsChanged,
    this.isEmbedded = true,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _selectedMethodId;
  late bool _masterNotifications;
  late Map<String, bool> _prayerNotifications;
  String _currentCityName = 'جاري التحديد...';

  final List<Map<String, String>> _prayers = const [
    {'key': 'fajr', 'name': 'صلاة الفجر'},
    {'key': 'dhuhr', 'name': 'صلاة الظهر'},
    {'key': 'asr', 'name': 'صلاة العصر'},
    {'key': 'maghrib', 'name': 'صلاة المغرب'},
    {'key': 'isha', 'name': 'صلاة العشاء'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _selectedMethodId = AppCache.instance.getCalculationMethod();
    _masterNotifications = AppCache.instance.getNotificationsEnabled();
    _currentCityName = LocationHelper.getCachedCityName();

    _prayerNotifications = {};
    for (final p in _prayers) {
      final key = p['key']!;
      _prayerNotifications[key] = AppCache.instance.isPrayerNotificationEnabled(key);
    }
  }

  String _getMethodTitle(int id) {
    final method = calculationMethods.firstWhere(
      (m) => m.id == id,
      orElse: () => calculationMethods.first,
    );
    return method.title;
  }

  Future<void> _openLocationDialog() async {
    final result = await showDialog<bool?>(
      context: context,
      builder: (context) => const GetCurrentLocation(),
    );

    if (result == true && mounted) {
      setState(() {
        _currentCityName = LocationHelper.getCachedCityName();
      });
      widget.onSettingsChanged?.call();
      _showSnackBar('تم تحديث الموقع بنجاح');
    }
  }

  void _showCalculationMethodPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: MuezzinTheme.cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: MuezzinTheme.primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calculate_rounded,
                        color: MuezzinTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'طريقة حساب مواقيت الصلاة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: MuezzinTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: MuezzinTheme.outlineColor),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: calculationMethods.length,
                  itemBuilder: (context, index) {
                    final method = calculationMethods[index];
                    final isSelected = method.id == _selectedMethodId;
                    return InkWell(
                      onTap: () async {
                        setState(() {
                          _selectedMethodId = method.id;
                        });
                        Navigator.pop(context);

                        await AppCache.instance.saveCalculationMethod(method.id);
                        await AppCache.instance.saveMonthOfPrayerTimes(-1);
                        widget.onSettingsChanged?.call();
                        _showSnackBar('تم تغيير طريقة الحساب إلى: ${method.title}');
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? MuezzinTheme.primaryColor.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? MuezzinTheme.primaryColor
                                : MuezzinTheme.outlineColor,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: isSelected
                                  ? MuezzinTheme.primaryColor
                                  : MuezzinTheme.disabledColor,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method.title,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isSelected
                                          ? MuezzinTheme.primaryColor
                                          : MuezzinTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    method.description,
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      color: MuezzinTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _rescheduleAlarms() async {
    final cached = AppCache.instance.getPrayerTimes();
    if (cached.isNotEmpty) {
      await PrayerAlarmService.scheduleUpcomingPrayers(cached);
    }
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
            child: const Text('حسناً', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _checkPermissions() async {
    final granted = await PrayerAlarmService.checkAndRequestPermissions();
    if (mounted) {
      _showSnackBar(
        granted
            ? 'تم التأكد من تفعيل أذونات التنبيهات والمنبه الدقيق'
            : 'يرجى مراجعة إعدادات الجهاز لمنح الإذن للمنبه الدقيق',
      );
    }
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: MuezzinTheme.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userPos = AppCache.instance.getUserLocation();

    final content = SafeArea(
      bottom: false,
      child: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
              children: [
                // 1. الموقع الجغرافي
                _buildSectionHeader(
                  title: 'الموقع الجغرافي',
                  icon: Icons.location_on_rounded,
                ),
                _buildCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: MuezzinTheme.primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.location_city_rounded,
                              color: MuezzinTheme.primaryColor,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'المدينة / المنطقة الحالية',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    color: MuezzinTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _currentCityName,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: MuezzinTheme.textPrimary,
                                  ),
                                ),
                                if (userPos != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '${userPos.latitude.toStringAsFixed(4)}°, ${userPos.longitude.toStringAsFixed(4)}°',
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11,
                                      color: MuezzinTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _openLocationDialog,
                            icon: const Icon(Icons.edit_location_alt_rounded, size: 16),
                            label: const Text('تغيير', style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MuezzinTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 2. طريقة الحساب
                _buildSectionHeader(
                  title: 'حساب المواقيت',
                  icon: Icons.calculate_rounded,
                ),
                _buildCard(
                  child: InkWell(
                    onTap: _showCalculationMethodPicker,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: MuezzinTheme.goldColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.mosque_rounded,
                              color: MuezzinTheme.goldColor,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'طريقة الحساب المعتمدة',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    color: MuezzinTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getMethodTitle(_selectedMethodId),
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: MuezzinTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: MuezzinTheme.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 3. تنبيهات الأذان
                _buildSectionHeader(
                  title: 'تنبيهات الأذان والصلوات',
                  icon: Icons.notifications_active_rounded,
                ),
                _buildCard(
                  child: Column(
                    children: [
                      // Master switch
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: MuezzinTheme.primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.volume_up_rounded,
                              color: MuezzinTheme.primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'تفعيل منبه الأذان بالصوت الكامل',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: MuezzinTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  'يعمل أثناء إغلاق الشاشة والوضع الصامت',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                    color: MuezzinTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _masterNotifications,
                            activeThumbColor: MuezzinTheme.goldColor,
                            onChanged: (val) async {
                              setState(() {
                                _masterNotifications = val;
                              });
                              await AppCache.instance.saveNotificationsEnabled(val);
                              await _rescheduleAlarms();
                              _showSnackBar(
                                val ? 'تم تفعيل منبه الأذان' : 'تم إيقاف منبه الأذان',
                              );
                            },
                          ),
                        ],
                      ),
                      if (_masterNotifications) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: MuezzinTheme.outlineColor),
                        ),
                        // Individual prayer toggles
                        ...List.generate(_prayers.length, (index) {
                          final prayer = _prayers[index];
                          final key = prayer['key']!;
                          final name = prayer['name']!;
                          final enabled = _prayerNotifications[key] ?? true;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const SizedBox(width: 8),
                                Icon(
                                  enabled ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                  color: enabled ? MuezzinTheme.goldColor : MuezzinTheme.disabledColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14,
                                      fontWeight: enabled ? FontWeight.bold : FontWeight.normal,
                                      color: enabled ? MuezzinTheme.textPrimary : MuezzinTheme.textSecondary,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: enabled,
                                  activeThumbColor: MuezzinTheme.primaryColor,
                                  onChanged: (val) async {
                                    setState(() {
                                      _prayerNotifications[key] = val;
                                    });
                                    await AppCache.instance.savePrayerNotificationEnabled(key, val);
                                    await _rescheduleAlarms();
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                      const SizedBox(height: 8),
                      // Permission check button
                      InkWell(
                        onTap: _checkPermissions,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: MuezzinTheme.primaryBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: MuezzinTheme.outlineColor),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.security_rounded, color: MuezzinTheme.primaryColor, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'التحقق من أذونات التنبيهات الدقيقة',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: MuezzinTheme.textPrimary,
                                  ),
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: MuezzinTheme.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 4. البوصلة ومعايرتها
                _buildSectionHeader(
                  title: 'البوصلة والقبلة',
                  icon: Icons.explore_rounded,
                ),
                _buildCard(
                  child: InkWell(
                    onTap: _showCalibrationDialog,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: MuezzinTheme.primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.screen_rotation_rounded,
                              color: MuezzinTheme.primaryColor,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'معايرة مستشعر البوصلة',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: MuezzinTheme.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'إرشادات تحريك الهاتف بدقة لتحديد اتجاه الكعبة المشرفة',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                    color: MuezzinTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: MuezzinTheme.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 5. حول التطبيق
                _buildSectionHeader(
                  title: 'معلومات التطبيق',
                  icon: Icons.info_outline_rounded,
                ),
                _buildCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: MuezzinTheme.goldColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.mosque_outlined,
                              color: MuezzinTheme.goldColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'المؤذن الذكي',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: MuezzinTheme.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'الإصدار 1.0.0',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    color: MuezzinTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: MuezzinTheme.primaryBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'اللهم اجعل هذا التطبيق صدقة جارية ونافعاً لجميع المسلمين، ولا تنسونا من صالح دعائكم.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: MuezzinTheme.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );

    if (widget.isEmbedded) {
      return content;
    }

    return Scaffold(
      body: Container(
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
        child: content,
      ),
    );
  }

  Widget _buildTopBar() {
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
            const SizedBox(width: 48),
          const Row(
            children: [
              Icon(Icons.settings_rounded, color: MuezzinTheme.textPrimary, size: 24),
              SizedBox(width: 8),
              Text(
                'الإعدادات',
                style: TextStyle(
                  color: MuezzinTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: MuezzinTheme.textPrimary.withValues(alpha: 0.8)),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: MuezzinTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return LiquidGlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(22),
      blur: 16,
      child: child,
    );
  }
}
