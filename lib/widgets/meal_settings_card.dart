import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/meal_schedule.dart';
import '../providers/settings_provider.dart';
import 'adaptive_widgets.dart';
import 'meal_range_editor.dart';
import 'settings_toggle_row.dart';


class MealSettingsCard extends ConsumerWidget {
  const MealSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final includeDinner = ref.watch(mealIncludeDinnerProvider);
    final schedule = ref.watch(mealScheduleProvider);

    return AdaptiveCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsToggleRow(
            icon: Icons.nightlight_round,
            title: 'Incluir cena',
            value: includeDinner,
            onChanged: (v) => ref
                .read(settingsNotifierProvider.notifier)
                .updateMealIncludeDinner(v),
            isLast: false,
          ),
          MealRangeEditor(
            icon: MealRangeEditor.iconFor('Desayuno'),
            mealName: 'Desayuno',
            range: schedule.desayuno,
            enabled: true,
            onRangeChanged: (r) => _update(ref, schedule, 'Desayuno', r),
          ),
          MealRangeEditor(
            icon: MealRangeEditor.iconFor('Almuerzo'),
            mealName: 'Almuerzo',
            range: schedule.almuerzo,
            enabled: true,
            onRangeChanged: (r) => _update(ref, schedule, 'Almuerzo', r),
          ),
          MealRangeEditor(
            icon: MealRangeEditor.iconFor('Once'),
            mealName: 'Once',
            range: schedule.once,
            enabled: true,
            onRangeChanged: (r) => _update(ref, schedule, 'Once', r),
          ),
          MealRangeEditor(
            icon: MealRangeEditor.iconFor('Cena'),
            mealName: 'Cena',
            range: schedule.cena,
            enabled: includeDinner,
            onRangeChanged: (r) => _update(ref, schedule, 'Cena', r),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Future<void> _update(
    WidgetRef ref,
    MealSchedule current,
    String meal,
    MealTimeRange range,
  ) async {
    final next = current.withRange(meal, range);
    await ref
        .read(settingsNotifierProvider.notifier)
        .updateMealSchedule(next);
  }
}
