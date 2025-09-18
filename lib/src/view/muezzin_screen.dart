import 'package:muezzin_flutter/core/theme/azkar_theme.dart';
import 'package:muezzin_flutter/src/logic/muezzin/muezzin_bloc.dart';
import 'package:muezzin_flutter/src/logic/muezzin/muezzin_state.dart';
import 'package:muezzin_flutter/src/view/widgets/dimond_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MuezzinScreen extends StatefulWidget {
  const MuezzinScreen({super.key});


  @override
  State<MuezzinScreen> createState() => _MuezzinScreenState();
}

class _MuezzinScreenState extends State<MuezzinScreen> {
  late MuezzinBloc bloc;


  @override
  void initState() {
    super.initState();
    bloc = MuezzinBloc();
    // Load azkar on screen start
    bloc.add(LoadMuezzin());
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "",
            style: TextStyle(
              color: MuezzinTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: MuezzinTheme.textPrimary,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(child: DiamondBackground()),
              BlocBuilder<MuezzinBloc, MuezzinState>(
                bloc: bloc,
                builder: (context, state) {
                  if (state.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.error) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(state.errorMessage ?? 'حدث خطأ غير متوقع'),
                      ),
                    );
                  }

                  final current = state.currentZeker;
                  if (current == null) {
                    return const Center(child: Text('لا توجد أذكار حالياً'));
                  }

                  final repetitions = (current.repetitions ?? 1);
                  final currentCount = state.currentCount;
                  final total = state.azkar.isEmpty ? 1 : state.azkar.length;
                  final idx = state.azkar.indexOf(current);
                  final progress = total == 0
                      ? 0.0
                      : ((idx + 1) / total).clamp(0.0, 1.0);

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        // Card + overlapping repeat bar section
                        _CardWithRepeat(
                          text: current.text ?? '',
                          count: currentCount,
                          max: repetitions,
                          onMinus: () => bloc.add(const DecrementCount()),
                          onPlus: () => bloc.add(const IncrementCount()),
                          onReset: () => bloc.add(const ResetCurrent()),
                        ),
                        const Spacer(),
                        _ProgressBar(value: progress),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => bloc.add(const PrevMuezzin()),
                              icon: Icon(
                                Icons.double_arrow_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              iconSize: 26,
                              tooltip: 'السابق',
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: const StadiumBorder(),
                                  elevation: 0,
                                ),
                                onPressed: () => bloc.add(const NextMuezzin()),
                                child: const Text('التالي'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
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
