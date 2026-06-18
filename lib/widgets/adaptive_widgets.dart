import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../constants/glass_settings.dart';
import '../theme/theme_style.dart';
import 'material_toast.dart';

bool _isGlass(WidgetRef ref) =>
    ref.watch(themeStyleProvider) == ThemeStyle.liquidGlass;

/// Versión pública de [_isGlass] para uso desde otros widgets
/// (no `ConsumerWidget`) que necesiten saber el estilo de tema activo.
bool isLiquidGlass(WidgetRef ref) =>
    ref.watch(themeStyleProvider) == ThemeStyle.liquidGlass;

/// Helpers de diseño responsivo basados en el ancho de la ventana.
///
/// Usa `LayoutBuilder` o `MediaQuery.sizeOf(context)` para evitar
/// `MediaQuery.of(context).size` (que es costoso y propaga rebuilds).
class Responsive {
  Responsive._();

  /// Ancho en el que se pasa de layout de móvil a layout con margen
  /// superior (tablet / escritorio).
  static const double tabletMinWidth = 600;

  /// Ancho en el que se considera un teléfono "estrecho" (< 360dp).
  /// Se usa para compactar anillos, stats y márgenes.
  static const double narrowPhoneMaxWidth = 360;

  static double widthOf(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool isNarrowPhone(BuildContext context) =>
      widthOf(context) < narrowPhoneMaxWidth;

  static bool isTabletOrLarger(BuildContext context) =>
      widthOf(context) >= tabletMinWidth;

  /// Ancho máximo que el contenido debe ocupar para mantener
  /// legibilidad en tablets/escritorio. En móvil devuelve
  /// `double.infinity`.
  static double contentMaxWidth(BuildContext context) =>
      isTabletOrLarger(context) ? 600 : double.infinity;

  /// Padding horizontal de pantalla en dp. Más generoso en tablets.
  static double horizontalPadding(BuildContext context) =>
      isTabletOrLarger(context) ? 32 : 20;
}

LiquidGlassSettings _glassSettings(BuildContext context) =>
    RecommendedGlassSettings.forStandard(Theme.of(context).brightness);

class AdaptiveCard extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final BorderRadius? borderRadius;

  const AdaptiveCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.borderColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveBorderColor =
        borderColor ?? Theme.of(context).colorScheme.outline.withValues(alpha: 0.4);
    final radius = borderRadius ?? BorderRadius.circular(24);

    if (_isGlass(ref)) {
      if (borderColor != null) {
        return Container(
          margin: margin,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: effectiveBorderColor, width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: GlassCard(
              padding: padding ?? const EdgeInsets.all(16),
              settings: RecommendedGlassSettings.forCard(Theme.of(context).brightness),
              child: child,
            ),
          ),
        );
      }
      if (borderRadius != null) {
        return ClipRRect(
          borderRadius: borderRadius!,
          child: GlassCard(
            margin: margin,
            padding: padding ?? const EdgeInsets.all(16),
            settings: RecommendedGlassSettings.forCard(Theme.of(context).brightness),
            child: child,
          ),
        );
      }
      return GlassCard(
        margin: margin,
        padding: padding ?? const EdgeInsets.all(16),
        settings: RecommendedGlassSettings.forCard(Theme.of(context).brightness),
        child: child,
      );
    }
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: radius,
        border: Border.all(
          color: effectiveBorderColor,
          width: borderColor != null ? 1.5 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class AdaptiveFilledButton extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double height;
  final double? width;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry padding;

  const AdaptiveFilledButton({
    super.key,
    required this.child,
    required this.onTap,
    this.height = 44,
    this.width,
    this.backgroundColor,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_isGlass(ref)) {
      return GlassButton.custom(
        onTap: onTap ?? () {},
        style: GlassButtonStyle.prominent,
        shape: const LiquidRoundedSuperellipse(borderRadius: 14),
        width: width,
        height: height,
        settings: _glassSettings(context),
        glowColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
        child: Padding(
          padding: padding,
          child: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white,
            ),
            child: child,
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
          backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
          foregroundColor: foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          padding: padding,
        ),
        child: child,
      ),
    );
  }
}

class AdaptiveOutlinedButton extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double height;
  final double? width;
  final EdgeInsetsGeometry padding;

  const AdaptiveOutlinedButton({
    super.key,
    required this.child,
    required this.onTap,
    this.height = 44,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_isGlass(ref)) {
      return GlassButton.custom(
        onTap: onTap ?? () {},
        shape: const LiquidRoundedSuperellipse(borderRadius: 14),
        width: width,
        height: height,
        settings: _glassSettings(context),
        child: Padding(
          padding: padding,
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: child,
          ),
        ),
      );
    }
    return SizedBox(
      height: height,
      width: width,
        child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          padding: padding,
        ),
        child: child,
      ),
    );
  }
}

class AdaptiveTextField extends ConsumerWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final bool obscureText;
  final int maxLines;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool autofocus;

  const AdaptiveTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.obscureText = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_isGlass(ref)) {
      return GlassTextField(
        controller: controller,
        placeholder: placeholder,
        maxLines: maxLines,
        useOwnLayer: true,
        focusNode: focusNode,
        autofocus: autofocus,
        settings: RecommendedGlassSettings.forInput(Theme.of(context).brightness),
      );
    }
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      onChanged: onChanged,
      focusNode: focusNode,
      autofocus: autofocus,
      decoration: InputDecoration(
        hintText: placeholder,
        prefixIcon: prefixIcon,
      ),
    );
  }
}

class AdaptiveChip extends ConsumerWidget {
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final Color? backgroundColor;
  final Color? textColor;

  const AdaptiveChip({
    super.key,
    required this.label,
    this.onTap,
    this.onDeleted,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_isGlass(ref)) {
      return GlassChip(
        label: label,
        onTap: onTap,
        settings: _glassSettings(context),
      );
    }
    if (onDeleted != null) {
      return InputChip(
        label: Text(label),
        onDeleted: onDeleted,
        deleteIcon: const Icon(Icons.close, size: 16),
      );
    }
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: backgroundColor,
      labelStyle: textColor != null ? TextStyle(color: textColor) : null,
    );
  }
}

class AdaptiveListTile extends ConsumerWidget {
  final Widget? leading;
  final Widget title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isLast;
  final EdgeInsetsGeometry? contentPadding;

  const AdaptiveListTile({
    super.key,
    this.leading,
    required this.title,
    this.trailing,
    this.onTap,
    this.isLast = false,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    if (_isGlass(ref)) {
      return GlassListTile(
        title: title,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        contentPadding: padding,
        isLast: isLast,
      );
    }
    return Column(
      children: [
        ListTile(
          leading: leading,
          title: title,
          trailing: trailing,
          onTap: onTap,
          contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16),
        ),
        if (!isLast)
          const Divider(height: 1),
      ],
    );
  }
}

class AdaptiveSwitchListTile extends ConsumerWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isLast;
  final EdgeInsetsGeometry? contentPadding;

  const AdaptiveSwitchListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    required this.value,
    required this.onChanged,
    this.isLast = false,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_isGlass(ref)) {
      return GlassListTile(
        title: title,
        leading: leading,
        contentPadding:
            contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        trailing: GlassSwitch(
          value: value,
          onChanged: onChanged ?? (_) {},
        ),
      );
    }
    return Column(
      children: [
        SwitchListTile(
          title: title,
          subtitle: subtitle,
          secondary: leading,
          value: value,
          onChanged: onChanged,
          contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16),
        ),
        if (!isLast)
          const Divider(height: 1),
      ],
    );
  }
}

class AdaptiveProgress extends StatelessWidget {
  final double? size;

  const AdaptiveProgress({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      if (_isGlass(ref)) {
        return const GlassProgressIndicator.circular();
      }
      return SizedBox(
        width: size ?? 24,
        height: size ?? 24,
        child: const CircularProgressIndicator(strokeWidth: 2.5),
      );
    });
  }
}

class AdaptiveDivider extends ConsumerWidget {
  const AdaptiveDivider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_isGlass(ref)) {
      return const GlassDivider();
    }
    return const Divider();
  }
}

class AdaptiveContainer extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const AdaptiveContainer({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.height,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_isGlass(ref)) {
      return GlassContainer(
        margin: margin,
        padding: padding,
        height: height,
        width: width,
        settings: _glassSettings(context),
        child: child,
      );
    }
    return Container(
      margin: margin,
      padding: padding,
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class AdaptiveGroupedSection extends ConsumerWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  final String? header;

  const AdaptiveGroupedSection({
    super.key,
    required this.children,
    this.margin,
    this.header,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_isGlass(ref)) {
      return GlassGroupedSection(
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        settings: RecommendedGlassSettings.forCard(Theme.of(context).brightness),
        children: children,
      );
    }
    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outline
                .withValues(alpha: 0.4),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (header != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  header!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class AdaptiveAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final bool centerTitle;

  const AdaptiveAppBar({
    super.key,
    this.title,
    this.actions,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_isGlass(ref)) {
      return GlassAppBar(
        title: title,
        actions: actions,
        centerTitle: centerTitle,
      );
    }
    return AppBar(
      title: title,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AdaptiveTabBar extends ConsumerWidget implements PreferredSizeWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTabSelected;

  const AdaptiveTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_isGlass(ref)) {
      return GlassTabBar(
        tabs: tabs.map((t) => GlassTab(label: t)).toList(),
        selectedIndex: selectedIndex,
        onTabSelected: onTabSelected ?? (_) {},
      );
    }
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        tabs: tabs.map((t) => Tab(text: t)).toList(),
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorColor: Theme.of(context).colorScheme.primary,
        dividerColor: Colors.transparent,
        onTap: onTabSelected,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

class AdaptiveDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    required List<AdaptiveDialogAction> actions,
    Color? barrierColor,
  }) {
    final container = ProviderScope.containerOf(context);
    final themeStyle = container.read(themeStyleProvider);
    if (themeStyle == ThemeStyle.liquidGlass) {
      return GlassDialog.show<T>(
        context: context,
        title: title,
        barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.6),
        content: content,
        actions: actions.map((a) => GlassDialogAction(
          label: a.label,
          isPrimary: a.isPrimary,
          onPressed: a.onPressed,
        )).toList(),
      );
    }
    return showDialog<T>(
      context: context,
      barrierColor: barrierColor,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Text(title),
          content: content,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          actions: actions
              .map((a) => Expanded(
                    child: SizedBox(
                      height: 48,
                      child: a.isPrimary
                          ? FilledButton(
                              onPressed: a.onPressed,
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                              ),
                              child: Text(
                                a.label,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : TextButton(
                              onPressed: a.onPressed,
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  side: const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                    width: 1.5,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                              ),
                              child: Text(
                                a.label,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                    ),
                  ))
              .toList()
              .expand((w) sync* {
            yield w;
            yield const SizedBox(width: 12);
          })
          .toList()
        ..removeLast(),
        );
      },
    );
  }
}

class AdaptiveDialogAction {
  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  const AdaptiveDialogAction({
    required this.label,
    this.isPrimary = false,
    required this.onPressed,
  });
}

enum AdaptiveToastVariant {
  success,
  info,
  warning,
  destructive,
}

class AdaptiveToast {
  static void show(
    BuildContext context, {
    required String message,
    AdaptiveToastVariant variant = AdaptiveToastVariant.success,
    IconData? icon,
  }) {
    final container = ProviderScope.containerOf(context);
    final themeStyle = container.read(themeStyleProvider);
    if (themeStyle == ThemeStyle.liquidGlass) {
      GlassToast.show(
        context,
        message: message,
        icon: icon != null ? Icon(icon) : Icon(_glassDefaultIcon(variant)),
        type: _toGlassType(variant),
        position: GlassToastPosition.top,
      );
      return;
    }
    MaterialToast.show(
      context,
      message: message,
      variant: _toMaterialVariant(variant),
      icon: icon ?? _materialDefaultIcon(variant),
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
  }) {
    show(context, message: message, variant: AdaptiveToastVariant.info);
  }

  static GlassToastType _toGlassType(AdaptiveToastVariant v) {
    switch (v) {
      case AdaptiveToastVariant.success:
        return GlassToastType.success;
      case AdaptiveToastVariant.info:
        return GlassToastType.info;
      case AdaptiveToastVariant.warning:
        return GlassToastType.warning;
      case AdaptiveToastVariant.destructive:
        return GlassToastType.error;
    }
  }

  static MaterialToastVariant _toMaterialVariant(AdaptiveToastVariant v) {
    switch (v) {
      case AdaptiveToastVariant.success:
        return MaterialToastVariant.success;
      case AdaptiveToastVariant.info:
        return MaterialToastVariant.info;
      case AdaptiveToastVariant.warning:
        return MaterialToastVariant.warning;
      case AdaptiveToastVariant.destructive:
        return MaterialToastVariant.destructive;
    }
  }

  static IconData _glassDefaultIcon(AdaptiveToastVariant v) {
    switch (v) {
      case AdaptiveToastVariant.success:
        return CupertinoIcons.check_mark_circled_solid;
      case AdaptiveToastVariant.info:
        return CupertinoIcons.info_circle_fill;
      case AdaptiveToastVariant.warning:
        return CupertinoIcons.exclamationmark_triangle_fill;
      case AdaptiveToastVariant.destructive:
        return CupertinoIcons.trash_fill;
    }
  }

  static IconData _materialDefaultIcon(AdaptiveToastVariant v) {
    switch (v) {
      case AdaptiveToastVariant.success:
        return Icons.check_circle_rounded;
      case AdaptiveToastVariant.info:
        return Icons.info_rounded;
      case AdaptiveToastVariant.warning:
        return Icons.warning_amber_rounded;
      case AdaptiveToastVariant.destructive:
        return Icons.delete_outline_rounded;
    }
  }
}

class AdaptiveActionSheet {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<AdaptiveActionSheetOption> options,
    VoidCallback? onCancel,
  }) {
    final container = ProviderScope.containerOf(context);
    final themeStyle = container.read(themeStyleProvider);
    if (themeStyle == ThemeStyle.liquidGlass) {
      showGlassActionSheet(
        context: context,
        title: title,
        actions: options.map((o) => GlassActionSheetAction(
          label: o.label,
          onPressed: () => o.onTap?.call(),
        )).toList(),
      );
      return Future.value();
    }
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ),
            ...options.map((o) => ListTile(
              title: Text(
                o.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: o.isDestructive ? Colors.red : null,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                o.onTap?.call();
              },
            )),
            const Divider(height: 1),
            ListTile(
              title: const Text('Cancelar', textAlign: TextAlign.center),
              onTap: () {
                Navigator.pop(ctx);
                onCancel?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AdaptiveActionSheetOption {
  final String label;
  final bool isDestructive;
  final VoidCallback? onTap;

  const AdaptiveActionSheetOption({
    required this.label,
    this.isDestructive = false,
    this.onTap,
  });
}
