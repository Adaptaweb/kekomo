import 'package:flutter/material.dart';

/// Caja cuadrada de 32dp con icono coloreado, usada como leading
/// en filas de ajustes / cards de estadísticas.
///
/// Centraliza el patrón (que estaba duplicado en `settings_toggle_row`,
/// `settings_action_row` y `settings_screen`).
class LeadingIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final double borderRadius;

  const LeadingIconBox({
    super.key,
    required this.icon,
    required this.color,
    this.size = 32,
    this.iconSize = 20,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}
