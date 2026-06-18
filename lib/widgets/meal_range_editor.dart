import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/meal_schedule.dart';
import 'adaptive_widgets.dart';
import 'leading_icon_box.dart';
import 'meal_time_picker_sheet.dart';
import 'section_divider.dart';

class MealRangeEditor extends ConsumerWidget {
  final IconData icon;
  final String mealName;
  final MealTimeRange range;
  final bool enabled;
  final ValueChanged<MealTimeRange> onRangeChanged;
  final bool isLast;

  const MealRangeEditor({
    super.key,
    required this.icon,
    required this.mealName,
    required this.range,
    required this.enabled,
    required this.onRangeChanged,
    this.isLast = false,
  });

  static const _mealIcons = {
    'Desayuno': Icons.free_breakfast,
    'Almuerzo': Icons.lunch_dining,
    'Once': Icons.coffee,
    'Cena': Icons.dinner_dining,
  };

  static IconData iconFor(String meal) => _mealIcons[meal] ?? Icons.restaurant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final disabledColor =
        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
    final iconFg =
        enabled ? primary : primary.withValues(alpha: 0.5);
    final nameColor =
        enabled ? theme.colorScheme.onSurface : disabledColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              LeadingIconBox(icon: icon, color: iconFg),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mealName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: nameColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (enabled) ...[
                MealTimeChip(
                  label: _formatTime(range.startHour, range.startMinute),
                  onTap: () => _pick(
                    context,
                    isStart: true,
                    initial: TimeOfDay(
                      hour: range.startHour,
                      minute: range.startMinute,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '-',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                MealTimeChip(
                  label: _formatTime(range.endHour, range.endMinute),
                  onTap: () => _pick(
                    context,
                    isStart: false,
                    initial: TimeOfDay(
                      hour: range.endHour,
                      minute: range.endMinute,
                    ),
                  ),
                ),
              ] else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Sin horario',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: disabledColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (!isLast) const SectionDivider(),
      ],
    );
  }

  Future<void> _pick(
    BuildContext context, {
    required bool isStart,
    required TimeOfDay initial,
  }) async {
    final newTime = await showMealTimePicker(
      context,
      title: '${isStart ? 'Inicio' : 'Fin'} - $mealName',
      initial: initial,
    );
    if (newTime == null) return;
    if (!context.mounted) return;

    final updated = isStart
        ? range.copyWith(
            startHour: newTime.hour,
            startMinute: newTime.minute,
          )
        : range.copyWith(
            endHour: newTime.hour,
            endMinute: newTime.minute,
          );

    final start = updated.startHour * 60 + updated.startMinute;
    final end = updated.endHour * 60 + updated.endMinute;
    if (end <= start) {
      AdaptiveToast.show(
        context,
        message: 'La hora de fin debe ser posterior a la de inicio',
        variant: AdaptiveToastVariant.warning,
      );
      return;
    }

    onRangeChanged(updated);
  }

  String _formatTime(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

class MealTimeChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const MealTimeChip({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
