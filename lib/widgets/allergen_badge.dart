import 'package:flutter/material.dart';

class AllergenBadge extends StatelessWidget {
  final String label;

  const AllergenBadge({super.key, required this.label});

  static const _bg = Color(0xFFFEE2E2);
  static const _border = Color(0xFFFECACA);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
