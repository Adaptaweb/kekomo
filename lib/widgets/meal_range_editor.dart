import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/meal_schedule.dart';
import 'adaptive_widgets.dart';
import 'meal_time_picker_sheet.dart';

class MealRangeEditor extends ConsumerWidget {
  final String icon;
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

  static const _mealEmojis = {
    'Desayuno': '☕',
    'Almuerzo': '🍔',
    'Once': '☕',
    'Cena': '🍽️',
  };

  static String emojiFor(String meal) => _mealEmojis[meal] ?? '🍽️';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final disabledColor =
        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
    final nameColor =
        enabled ? const Color(0xFF0F172A) : disabledColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(
            icon,
            style: TextStyle(
              fontSize: 24,
              color: enabled
                  ? null
                  : Colors.black.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mealName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
                color: const Color(0xFFE5E7EB),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFD1EAD9).withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFD1EAD9).withValues(alpha: 0.6),
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }
}
