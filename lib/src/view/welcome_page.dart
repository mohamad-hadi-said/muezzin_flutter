import 'package:muezzin_flutter/core/theme/muezzin_theme.dart';
import 'package:muezzin_flutter/core/utils/toast.dart';
import 'package:muezzin_flutter/src/logic/home/home_bloc.dart';
import 'package:muezzin_flutter/src/logic/home/home_state.dart';
import 'package:muezzin_flutter/src/view/muezzin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muezzin_flutter/src/view/widgets/get_current_location.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  bool loadingAd = false;

  HomeBloc bloc = HomeBloc();

  @override
  void initState() {
    super.initState();
    bloc.add(LoadHome());
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                // Header-like card matching Muezzin screen
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: const [
                          Expanded(
                            child: Center(
                              child: Text(
                                'مواقيتي',
                                style: TextStyle(
                                  color: MuezzinTheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'مرحبًا بك! يمكنك الدخول إلى شاشة المواقيت لمعرفة مواقيت الصلاة في منطقتك.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: MuezzinTheme.onPrimary.withOpacity(0.95),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: MuezzinTheme.primaryColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _navigateToMuezzin,
                          child: const Text('الدخول إلى المواقيت'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: MuezzinTheme.primaryColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            final result = await showDialog<bool?>(
                              context: context,
                              builder: (context) => const GetCurrentLocation(),
                            );
                            if (result != null && result) {
                              bloc.add(LoadHome());
                            }
                          },
                          label: const Text('تحديد موقعي الحالي'),
                          icon: const Icon(Icons.location_on),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
