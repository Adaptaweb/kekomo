import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'adaptive_widgets.dart';

class _PickerResult {
  final TimeOfDay? value;
  final bool confirmed;
  const _PickerResult(this.value, this.confirmed);
}

Future<TimeOfDay?> showMealTimePicker(
  BuildContext context, {
  required String title,
  required TimeOfDay initial,
}) async {
  TimeOfDay working = initial;

  final result = await showModalBottomSheet<_PickerResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final t = Theme.of(ctx);
      return Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom +
              MediaQuery.of(ctx).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: t.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(
                        ctx,
                        const _PickerResult(null, false),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          title,
                          style: t.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(
                        ctx,
                        _PickerResult(working, true),
                      ),
                      child: const Text('Aceptar'),
                    ),
                  ],
                ),
              ),
              const AdaptiveDivider(),
              SizedBox(
                height: 220,
                child: FocusScope(
                  canRequestFocus: false,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    initialDateTime: DateTime(
                      2024,
                      1,
                      1,
                      initial.hour,
                      initial.minute,
                    ),
                    onDateTimeChanged: (dt) {
                      working = TimeOfDay(hour: dt.hour, minute: dt.minute);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );

  if (result?.confirmed == true) {
    return result!.value;
  }
  return null;
}
