import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/meal_schedule.dart';
import '../providers/navigation_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/adaptive_widgets.dart';
import '../widgets/adaptive_button.dart';
import '../widgets/meal_range_editor.dart';
import '../widgets/section_divider.dart';
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Image.asset(
                'assets/icon/welcome.png',
                width: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 28),
              Text(
                firstName.isEmpty ? '¡Bienvenido!' : '¡Bienvenido $firstName!',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vamos a configurar tus comidas diarias.\nPuedes cambiarlas más tarde en Ajustes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              AdaptiveCard(
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
                    const SectionDivider(),
                    MealRangeEditor(
                      icon: MealRangeEditor.iconFor('Desayuno'),
                      mealName: 'Desayuno',
                      range: _localSchedule.desayuno,
                      enabled: true,
                      onRangeChanged: (r) => _updateRange('Desayuno', r),
                    ),
                    const SectionDivider(),
                    MealRangeEditor(
                      icon: MealRangeEditor.iconFor('Almuerzo'),
                      mealName: 'Almuerzo',
                      range: _localSchedule.almuerzo,
                      enabled: true,
                      onRangeChanged: (r) => _updateRange('Almuerzo', r),
                    ),
                    const SectionDivider(),
                    MealRangeEditor(
                      icon: MealRangeEditor.iconFor('Once'),
                      mealName: 'Once',
                      range: _localSchedule.once,
                      enabled: true,
                      onRangeChanged: (r) => _updateRange('Once', r),
                    ),
                    const SectionDivider(),
                    MealRangeEditor(
                      icon: MealRangeEditor.iconFor('Cena'),
                      mealName: 'Cena',
                      range: _localSchedule.cena,
                      enabled: _cenaEnabled,
                      onRangeChanged: (r) => _updateRange('Cena', r),
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: AdaptiveButton(
                  height: 56,
                  onTap: _onConfirm,
                  child: const Text(
                    'CONFIRMAR Y EMPEZAR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Puedes ajustar estos valores en cualquier momento\ndesde la pestaña Ajustes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
