import 'dart:async';
import 'package:flutter/material.dart';

enum MaterialToastVariant {
  success,
  info,
  warning,
  destructive,
}

class MaterialToast {
  static VoidCallback show(
    BuildContext context, {
    required String message,
    required MaterialToastVariant variant,
    IconData? icon,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    final overlayState = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;

    void dismiss() {
      if (entry.mounted) entry.remove();
    }

    entry = OverlayEntry(
      builder: (_) => _MaterialToastOverlay(
        message: message,
        variant: variant,
        icon: icon,
        duration: duration,
        onDismissed: dismiss,
      ),
    );

    overlayState.insert(entry);
    return dismiss;
  }
}

class _MaterialToastOverlay extends StatefulWidget {
  const _MaterialToastOverlay({
    required this.message,
    required this.variant,
    required this.duration,
    required this.onDismissed,
    this.icon,
  });

  final String message;
  final MaterialToastVariant variant;
  final Duration duration;
  final VoidCallback onDismissed;
  final IconData? icon;

  @override
  State<_MaterialToastOverlay> createState() => _MaterialToastOverlayState();
}

class _MaterialToastOverlayState extends State<_MaterialToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.6),
      reverseCurve: const Interval(0.4, 1),
    ));
    _controller.forward();
    if (widget.duration > Duration.zero) {
      _timer = Timer(widget.duration, _dismiss);
    }
  }

  Future<void> _dismiss() async {
    _timer?.cancel();
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final accent = _resolveAccent(scheme);
    final surface = isDark
        ? scheme.surfaceContainerHigh.withValues(alpha: 0.96)
        : scheme.surface.withValues(alpha: 0.96);
    final onSurface = scheme.onSurface;

    final iconData = widget.icon ?? _defaultIcon();

    Widget toast = Semantics(
      liveRegion: true,
      label: widget.message,
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48, maxWidth: 480),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: accent.withValues(alpha: 0.28),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.18),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconData, color: accent, size: 20),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  widget.message,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: onSurface,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.5,
                    letterSpacing: -0.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    toast = Dismissible(
      key: const Key('material_toast_dismissible'),
      direction: DismissDirection.up,
      onDismissed: (_) => _dismiss(),
      child: toast,
    );

    return Positioned(
      top: mq.padding.top + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(opacity: _fade, child: toast),
      ),
    );
  }

  Color _resolveAccent(ColorScheme scheme) {
    switch (widget.variant) {
      case MaterialToastVariant.success:
        return scheme.primary;
      case MaterialToastVariant.info:
        return scheme.tertiary;
      case MaterialToastVariant.warning:
        return scheme.tertiary;
      case MaterialToastVariant.destructive:
        return const Color(0xFFFF3B30);
    }
  }

  IconData _defaultIcon() {
    switch (widget.variant) {
      case MaterialToastVariant.success:
        return Icons.check_circle_rounded;
      case MaterialToastVariant.info:
        return Icons.info_rounded;
      case MaterialToastVariant.warning:
        return Icons.warning_amber_rounded;
      case MaterialToastVariant.destructive:
        return Icons.delete_outline_rounded;
    }
  }
}
