import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/theme_style.dart';

class OptionToggleRow extends ConsumerWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const OptionToggleRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGlass = ref.watch(themeStyleProvider) == ThemeStyle.liquidGlass;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        if (isGlass)
          GlassSwitch(value: value, onChanged: onChanged)
        else
          Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
