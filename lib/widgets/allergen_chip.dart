import 'package:flutter/material.dart';

class AllergenChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const AllergenChip({
    super.key,
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  static const _selectedBorder = Color(0xFFFECACA);
  static const _selectedBg = Color(0xFFFFF5F5);
  static const _selectedIconBg = Color(0xFFFEE2E2);
  static const _selectedFg = Color(0xFFEF4444);
  static const _unselectedBorder = Color(0xFFE5E7EB);
  static const _unselectedIconBg = Color(0xFFF3F4F6);
  static const _unselectedFg = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? _selectedBorder : _unselectedBorder;
    final bgColor = isSelected ? _selectedBg : Colors.white;
    final iconBg = isSelected ? _selectedIconBg : _unselectedIconBg;
    final fg = isSelected ? _selectedFg : _unselectedFg;
    final labelWeight = isSelected ? FontWeight.w700 : FontWeight.w500;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  emoji,
                  style: TextStyle(
                    fontSize: 20,
                    color: fg,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: labelWeight,
                  color: fg,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
