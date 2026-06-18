import 'package:flutter/material.dart';
import 'adaptive_widgets.dart';

/// Divisor horizontal con padding horizontal estándar,
/// pensado para secciones dentro de tarjetas agrupadas.
class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: AdaptiveDivider(),
    );
  }
}
