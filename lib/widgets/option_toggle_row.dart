import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/theme_style.dart';

class OptionToggleRow extends ConsumerWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const OptionToggleRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isGlass = ref.watch(themeStyleProvider) == ThemeStyle.liquidGlass;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              if (isGlass)
                GlassSwitch(value: value, onChanged: onChanged)
              else
                Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 0.5,
              color: theme.colorScheme.outline.withValues(alpha: 0.15),
            ),
          ),
      ],
    );
  }
}
