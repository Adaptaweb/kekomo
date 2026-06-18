import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryOption {
  final String value;
  final String svgAsset;
  final String svgAssetSelected;
  final String label;

  const CategoryOption({
    required this.value,
    required this.svgAsset,
    required this.svgAssetSelected,
    required this.label,
  });
}

const List<CategoryOption> kCategoryOptions = [
  CategoryOption(
    value: 'Madre',
    svgAsset: 'assets/icon/mama.svg',
    svgAssetSelected: 'assets/icon/mama_filled.svg',
    label: 'Madre',
  ),
  CategoryOption(
    value: 'Padre',
    svgAsset: 'assets/icon/padre.svg',
    svgAssetSelected: 'assets/icon/padre_filled.svg',
    label: 'Padre',
  ),
  CategoryOption(
    value: 'Hijo',
    svgAsset: 'assets/icon/hijo.svg',
    svgAssetSelected: 'assets/icon/hijo_filled.svg',
    label: 'Hijo',
  ),
  CategoryOption(
    value: 'Hija',
    svgAsset: 'assets/icon/hija.svg',
    svgAssetSelected: 'assets/icon/hija_filled.svg',
    label: 'Hija',
  ),
];

class CategorySelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const CategorySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final unselectedBg = theme.colorScheme.surfaceContainerHighest;
    final unselectedFg = theme.colorScheme.onSurfaceVariant;

    return Row(
      children: [
        for (int i = 0; i < kCategoryOptions.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _CategoryTile(
              option: kCategoryOptions[i],
              selected: kCategoryOptions[i].value == value,
              primary: primary,
              onPrimary: onPrimary,
              unselectedBg: unselectedBg,
              unselectedFg: unselectedFg,
              onTap: () => onChanged(kCategoryOptions[i].value),
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryOption option;
  final bool selected;
  final Color primary;
  final Color onPrimary;
  final Color unselectedBg;
  final Color unselectedFg;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.option,
    required this.selected,
    required this.primary,
    required this.onPrimary,
    required this.unselectedBg,
    required this.unselectedFg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? primary : unselectedBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected
                  ? primary
                  : Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                selected ? option.svgAssetSelected : option.svgAsset,
                width: 24,
                height: 24,
                colorFilter: selected
                    ? null
                    : ColorFilter.mode(unselectedFg, BlendMode.srcIn),
              ),
              const SizedBox(height: 4),
              Text(
                option.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? onPrimary : unselectedFg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
