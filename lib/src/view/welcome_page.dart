import 'package:muezzin_flutter/core/theme/muezzin_theme.dart';
import 'package:muezzin_flutter/core/utils/toast.dart';
import 'package:muezzin_flutter/src/logic/home/home_bloc.dart';
import 'package:muezzin_flutter/src/logic/home/home_state.dart';
import 'package:muezzin_flutter/src/view/muezzin_screen.dart';
import 'package:muezzin_flutter/src/view/widgets/dimond_background.dart';
import 'package:flutter/material.dart';
import 'package:muezzin_flutter/core/cache/app_cache.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  static const int _dailyAdLimit = 30;
  int _remainingAdsToday = 30;

  bool loadingAd = false;

  HomeBloc bloc = HomeBloc();

  @override
  void initState() {
    super.initState();
    bloc.add(LoadHome());
    _refreshRemaining();
  }

  void _refreshRemaining() {
    try {
      _remainingAdsToday = AppCache.instance.getRemainingAdsToday(
        _dailyAdLimit,
      );
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      bloc: bloc,
      listener: (context, state) {
        if (state.error) {
          Toast.error(context, state.errorMessage ?? '');
        }
      },
      child: Scaffold(
        backgroundColor: MuezzinTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Text(
              'مواقيتي',
              style: TextStyle(
                color: MuezzinTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.search, color: MuezzinTheme.textPrimary),
            onPressed: () {},
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.dark_mode_outlined,
                color: MuezzinTheme.textPrimary,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(child: DiamondBackground()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Muezzin Cards
                      _buildMuezzinCard(
                        title: 'أذكار الصباح',
                        subtitle: 'بعد صلاة الفجر حتى شروق الشمس',
                        image: 'assets/images/morning.png',
                        icon: Icons.wb_sunny,
                        onTap: () => _navigateToMuezzin(),
                      ),

                      const SizedBox(height: 32),

                      // Stats Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: MuezzinTheme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'إحصائيات',
                                style: TextStyle(
                                  color: MuezzinTheme.primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    '${AppCache.instance.getTimesPlayed()}',
                                    'مرات القراءة',
                                  ),
                                  _buildStatItem(
                                    "${AppCache.instance.getAdPoints()}",
                                    'النقاط',
                                  ),
                                  _buildStatItem(
                                    '$_remainingAdsToday',
                                    'إعلانات اليوم',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                       
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: MuezzinTheme.primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: MuezzinTheme.textSecondary, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMuezzinCard({
    required String title,
    required String subtitle,
    required String image,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                  ),
                ),
              ),
            ),
            // Icon
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
            ),
            // Text content
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _navigateToMuezzin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MuezzinScreen(),
      ),
    );
  }

  Future<dynamic> showAboutOusDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('من نحن؟'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "شركة إيكونوميكس - ECONOMIX",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "منصة سورية مبتكرة تهدف إلى توفير فرص عمل حقيقية عبر الإنترنت، بما يتناسب مع ظروف الشباب السوري داخل البلاد.",
            ),
            const SizedBox(height: 16),
            Text(
              "🎯 ماذا نقدم؟  ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "- وظائف عن بعد في مجالات متنوعة (تسويق، إدخال بيانات، تصميم، دعم فني...)",
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('حسنا'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
