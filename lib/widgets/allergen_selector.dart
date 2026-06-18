import 'package:flutter/material.dart';
import '../data/allergen_icons.dart';
import '../data/allergen_knowledge_base.dart';
import 'allergen_chip.dart';

class AllergenSelector extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final bool showFooter;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final List<String> allergens;

  const AllergenSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.showFooter = false,
    this.onSave,
    this.onCancel,
    this.allergens = const [],
  });

  void _toggle(String allergen) {
    final next = Set<String>.from(selected);
    if (next.contains(allergen)) {
      next.remove(allergen);
    } else {
      next.add(allergen);
    }
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final list = allergens.isNotEmpty ? allergens : allergenCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final double aspectRatio;
            if (width < 360) {
              aspectRatio = 0.70;
            } else if (width < 450) {
              aspectRatio = 0.78;
            } else {
              aspectRatio = 0.85;
            }
            return GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: aspectRatio,
              children: [
                for (final allergen in list)
                  AllergenChip(
                    label: allergen,
                    emoji: emojiForAllergen(allergen),
                    isSelected: selected.contains(allergen),
                    onTap: () => _toggle(allergen),
                  ),
              ],
            );
          },
        ),
        if (showFooter) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                    label: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: const BorderSide(
                          color: Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: onSave,
                    icon: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text(
                      'Guardar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
