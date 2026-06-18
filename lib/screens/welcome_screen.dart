import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/meal_schedule.dart';
import '../providers/navigation_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/adaptive_widgets.dart';
import '../widgets/adaptive_button.dart';
import '../widgets/meal_range_editor.dart';
import '../widgets/settings_toggle_row.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  MealSchedule _localSchedule = MealSchedule.defaultSchedule();
  bool _cenaEnabled = true;

  @override
  void initState() {
    super.initState();
    _localSchedule = ref.read(mealScheduleProvider);
    Future.microtask(() async {
      await ref.read(settingsNotifierProvider.notifier).loadSettings();
      if (!mounted) return;
      setState(() {
        _localSchedule = ref.read(mealScheduleProvider);
      });
    });
  }

  Future<void> _onConfirm() async {
    await ref
        .read(settingsNotifierProvider.notifier)
        .updateMealSchedule(_localSchedule);
    await ref
        .read(settingsNotifierProvider.notifier)
        .updateMealIncludeDinner(_cenaEnabled);
    if (!mounted) return;
    ref.read(currentScreenProvider.notifier).state = KeComoScreen.today;
  }

  void _updateRange(String meal, MealTimeRange range) {
    setState(() {
      _localSchedule = _localSchedule.withRange(meal, range);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(activeProfileProvider);
    final firstName = profileAsync.value?.firstName ?? '';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/icon/welcome.png',
                      width: 140,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: const Color(0xFF0F172A),
                        ),
                        children: [
                          const TextSpan(text: '¡Bienvenido '),
                          TextSpan(
                            text: firstName.isEmpty ? '!' : '$firstName!',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Vamos a configurar tus comidas diarias.\nPuedes cambiarlas más tarde en Ajustes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AdaptiveCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SettingsToggleRow(
                        icon: Icons.nightlight_round,
                        title: 'Incluir cena',
                        value: _cenaEnabled,
                        onChanged: (v) => setState(() => _cenaEnabled = v),
                        isLast: false,
                      ),
                      const SizedBox(height: 1),
                      MealRangeEditor(
                        icon: '☕',
                        mealName: 'Desayuno',
                        range: _localSchedule.desayuno,
                        enabled: true,
                        onRangeChanged: (r) => _updateRange('Desayuno', r),
                      ),
                      const SizedBox(height: 1),
                      MealRangeEditor(
                        icon: '🍔',
                        mealName: 'Almuerzo',
                        range: _localSchedule.almuerzo,
                        enabled: true,
                        onRangeChanged: (r) => _updateRange('Almuerzo', r),
                      ),
                      const SizedBox(height: 1),
                      MealRangeEditor(
                        icon: '☕',
                        mealName: 'Once',
                        range: _localSchedule.once,
                        enabled: true,
                        onRangeChanged: (r) => _updateRange('Once', r),
                      ),
                      const SizedBox(height: 1),
                      MealRangeEditor(
                        icon: '🍽️',
                        mealName: 'Cena',
                        range: _localSchedule.cena,
                        enabled: _cenaEnabled,
                        onRangeChanged: (r) => _updateRange('Cena', r),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: AdaptiveButton(
                    height: 52,
                    onTap: _onConfirm,
                    child: const Text(
                      'CONFIRMAR Y EMPEZAR',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Puedes ajustar estos valores en cualquier momento\ndesde la pestaña Ajustes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
