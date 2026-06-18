import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lgw;
import '../constants/glass_settings.dart';
import 'adaptive_widgets.dart';

/// Variante visual de [AdaptiveButton].
enum AdaptiveButtonVariant {
  /// Botón principal: color primario, prominent glass / `FilledButton`.
  primary,

  /// Botón secundario: outlined, sin glow / `OutlinedButton`.
  secondary,

  /// Botón destructivo: color de error, prominent glass / `FilledButton` error.
  destructive,

  /// Pill sólido con icono opcional (sin efecto glass).
  pill,
}

/// Botón unificado con adapt glass ↔ material.
///
/// Reemplaza los antiguos `GlassPrimaryButton`, `GlassSecondaryButton`,
/// `GlassDestructiveButton` y `PillButton`. Se llama `AdaptiveButton` para
/// no chocar con `GlassButton` del paquete `liquid_glass_widgets`.
class AdaptiveButton extends ConsumerWidget {
  final Widget? child;

  /// Construye un botón a partir de un `label` (y opcional `icon`).
  /// Se ignora si se pasa [child].
  final String? label;
  final IconData? icon;

  final VoidCallback? onTap;
  final AdaptiveButtonVariant variant;
  final double height;
  final double? width;
  final EdgeInsetsGeometry padding;

  /// Color de fondo (sólo para [AdaptiveButtonVariant.pill]).
  final Color? backgroundColor;

  /// Color de primer plano (sólo para [AdaptiveButtonVariant.pill]).
  final Color? foregroundColor;

  const AdaptiveButton({
    super.key,
    this.child,
    this.label,
    this.icon,
    required this.onTap,
    this.variant = AdaptiveButtonVariant.primary,
    this.height = 44,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.backgroundColor,
    this.foregroundColor,
  }) : assert(child != null || label != null,
            'AdaptiveButton requiere child o label');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGlass = isLiquidGlass(ref);
    final content = child ?? _buildLabelContent(context);

    switch (variant) {
      case AdaptiveButtonVariant.primary:
        return _buildPrimary(context, isGlass, content);
      case AdaptiveButtonVariant.secondary:
        return _buildSecondary(context, isGlass, content);
      case AdaptiveButtonVariant.destructive:
        return _buildDestructive(context, isGlass, content);
      case AdaptiveButtonVariant.pill:
        return _buildPill(context, content);
    }
  }

  Widget _buildLabelContent(BuildContext context) {
    final base = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: foregroundColor,
    );
    if (icon == null) {
      return Text(
        label!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: base,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: foregroundColor),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: base,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimary(BuildContext context, bool isGlass, Widget content) {
    if (isGlass) {
      return lgw.GlassButton.custom(
        onTap: onTap ?? () {},
        style: lgw.GlassButtonStyle.prominent,
        shape: const lgw.LiquidRoundedSuperellipse(borderRadius: 22),
        width: width,
        height: height,
        glowColor: Theme.of(context).colorScheme.primary,
        child: Padding(
          padding: padding,
          child: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white,
            ),
            child: content,
          ),
        ),
      );
    }
    return SizedBox(
      height: height,
      width: width,
      child: FilledButton(
        onPressed: onTap,
        child: Padding(padding: padding, child: content),
      ),
    );
  }

  Widget _buildSecondary(BuildContext context, bool isGlass, Widget content) {
    if (isGlass) {
      return lgw.GlassButton.custom(
        onTap: onTap ?? () {},
        shape: const lgw.LiquidRoundedSuperellipse(borderRadius: 22),
        width: width,
        height: height,
        child: Padding(
          padding: padding,
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: content,
          ),
        ),
      );
    }
    return SizedBox(
      height: height,
      width: width,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(padding: padding),
        child: content,
      ),
    );
  }

  Widget _buildDestructive(BuildContext context, bool isGlass, Widget content) {
    const red = RecommendedGlassSettings.destructiveRed;
    if (isGlass) {
      return lgw.GlassButton.custom(
        onTap: onTap ?? () {},
        style: lgw.GlassButtonStyle.prominent,
        shape: const lgw.LiquidRoundedSuperellipse(borderRadius: 22),
        width: width,
        height: height,
        glowColor: red.withValues(alpha: 0.4),
        child: Padding(
          padding: padding,
          child: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white,
            ),
            child: content,
          ),
        ),
      );
    }
    return SizedBox(
      height: height,
      width: width,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
        ),
        child: Padding(padding: padding, child: content),
      ),
    );
  }

  Widget _buildPill(BuildContext context, Widget content) {
    final bg = backgroundColor ?? Theme.of(context).colorScheme.primary;
    final fg = foregroundColor ?? Colors.white;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
