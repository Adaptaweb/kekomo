import 'package:flutter/material.dart';

Color progressColor(double progress) {
  const targetGreen = Color(0xFF56A77F);
  final p = progress.clamp(0.0, 1.0);
  final targetHsl = HSLColor.fromColor(targetGreen);
  final hue = p * targetHsl.hue;
  final saturation = 0.85 - p * (0.85 - targetHsl.saturation);
  final lightness = 0.55 - p * (0.55 - targetHsl.lightness);
  return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
}

List<Color> barGradientColors(int value, int maxPerDay) {
  final p = maxPerDay > 0 ? value / maxPerDay : 0.0;
  final c = progressColor(p);
  return [c, c.withValues(alpha: 0.55)];
}
