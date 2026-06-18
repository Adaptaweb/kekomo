import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class RecommendedGlassSettings {
  const RecommendedGlassSettings._();

  static const _appleLightAngle = 0.75 * math.pi;

  static const destructiveRed = Color(0xFFFF3B30);

  // ── Dark mode ──────────────────────────────────────────────

  static const standard = LiquidGlassSettings(
    blur: 4,
    thickness: 10,
    glassColor: Color.fromRGBO(255, 255, 255, 0.08),
    lightAngle: _appleLightAngle,
    lightIntensity: 0.7,
    ambientStrength: 0,
    saturation: 1.2,
    refractiveIndex: 1.2,
    chromaticAberration: 0.01,
    specularSharpness: GlassSpecularSharpness.medium,
  );

  static const bottomBar = LiquidGlassSettings(
    glassColor: Color.fromRGBO(255, 255, 255, 0.08),
    thickness: 30,
    blur: 3,
    chromaticAberration: 0.01,
    lightAngle: GlassDefaults.lightAngle,
    lightIntensity: 0.5,
    ambientStrength: 0,
    refractiveIndex: 1.2,
    saturation: 1.2,
    specularSharpness: GlassSpecularSharpness.medium,
  );

  static const overlay = LiquidGlassSettings(
    blur: 10,
    thickness: 10,
    glassColor: Color.fromRGBO(255, 255, 255, 0.12),
    lightAngle: _appleLightAngle,
    lightIntensity: 0.7,
    ambientStrength: 0.4,
    saturation: 1.2,
    refractiveIndex: 0.7,
    chromaticAberration: 0.0,
  );

  static const input = LiquidGlassSettings(
    blur: 20,
    thickness: 10,
    glassColor: Color.fromRGBO(255, 255, 255, 0.12),
    lightAngle: _appleLightAngle,
    lightIntensity: 0.7,
    ambientStrength: 0.4,
    saturation: 1.2,
    refractiveIndex: 0.7,
    chromaticAberration: 0.0,
  );

  static const card = LiquidGlassSettings(
    thickness: 5,
    ambientStrength: 0.5,
    lightIntensity: 0.5,
    lightAngle: _appleLightAngle,
    glassColor: Color(0x66000000),
  );

  // ── Light mode ─────────────────────────────────────────────

  static const standardLight = LiquidGlassSettings(
    blur: 4,
    thickness: 10,
    glassColor: Color.fromRGBO(255, 255, 255, 0),
    lightAngle: _appleLightAngle,
    lightIntensity: 0.5,
    ambientStrength: 0.1,
    saturation: 1.0,
    refractiveIndex: 1.2,
    chromaticAberration: 0.01,
    specularSharpness: GlassSpecularSharpness.medium,
  );

  static const bottomBarLight = LiquidGlassSettings(
    glassColor: Color.fromRGBO(255, 255, 255, 0),
    thickness: 30,
    blur: 3,
    chromaticAberration: 0.01,
    lightAngle: GlassDefaults.lightAngle,
    lightIntensity: 0.5,
    ambientStrength: 0,
    refractiveIndex: 1.2,
    saturation: 1.2,
    specularSharpness: GlassSpecularSharpness.medium,
  );

  static const overlayLight = LiquidGlassSettings(
    blur: 10,
    thickness: 10,
    glassColor: Color.fromRGBO(255, 255, 255, 0),
    lightAngle: _appleLightAngle,
    lightIntensity: 0.5,
    ambientStrength: 0.2,
    saturation: 1.0,
    refractiveIndex: 0.7,
    chromaticAberration: 0.0,
  );

  static const inputLight = LiquidGlassSettings(
    blur: 20,
    thickness: 10,
    glassColor: Color.fromRGBO(255, 255, 255, 0),
    lightAngle: _appleLightAngle,
    lightIntensity: 0.5,
    ambientStrength: 0.2,
    saturation: 1.0,
    refractiveIndex: 0.7,
    chromaticAberration: 0.0,
  );

  static const cardLight = LiquidGlassSettings(
    thickness: 5,
    ambientStrength: 0.3,
    lightIntensity: 0.3,
    lightAngle: _appleLightAngle,
    glassColor: Color.fromARGB(0, 0, 0, 0),
  );

  // ── Helpers ────────────────────────────────────────────────

  static LiquidGlassSettings forCard(Brightness brightness) =>
      brightness == Brightness.light ? cardLight : card;

  static LiquidGlassSettings forBottomBar(Brightness brightness) =>
      brightness == Brightness.light ? bottomBarLight : bottomBar;

  static LiquidGlassSettings forStandard(Brightness brightness) =>
      brightness == Brightness.light ? standardLight : standard;

  static LiquidGlassSettings forOverlay(Brightness brightness) =>
      brightness == Brightness.light ? overlayLight : overlay;

  static LiquidGlassSettings forInput(Brightness brightness) =>
      brightness == Brightness.light ? inputLight : input;
}
