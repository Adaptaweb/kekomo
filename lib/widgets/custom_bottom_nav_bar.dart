import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../constants/glass_settings.dart';
import 'profile_button.dart';

class NavTabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class CustomBottomNavBar extends StatelessWidget {
  final int? currentIndex;
  final ValueChanged<int> onTabSelected;
  final bool isGlass;
  final double profileButtonSize;

  static const List<NavTabItem> tabs = [
    NavTabItem(
      icon: CupertinoIcons.sun_max,
      activeIcon: CupertinoIcons.sun_max_fill,
      label: 'Hoy',
    ),
    NavTabItem(
      icon: CupertinoIcons.calendar,
      activeIcon: CupertinoIcons.calendar_circle_fill,
      label: 'Calendario',
    ),
    NavTabItem(
      icon: CupertinoIcons.chart_bar,
      activeIcon: CupertinoIcons.chart_bar_fill,
      label: 'Resumen',
    ),
    NavTabItem(
      icon: CupertinoIcons.settings,
      activeIcon: CupertinoIcons.settings_solid,
      label: 'Ajustes',
    ),
  ];

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.isGlass,
    this.profileButtonSize = 60,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurfaceVariant;
    final onActiveColor = theme.colorScheme.onPrimary;

    const barHeight = 76.0;
    const horizontalPadding = 12.0;
    const centerGap = 12.0;

    final activeIndex = currentIndex;

    final tabRow = Padding(
      padding: const EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 0),
      child: Row(
        children: [
          _TabContent(
            item: tabs[0],
            isActive: activeIndex == 0,
            onTap: () => onTabSelected(0),
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            onActiveColor: onActiveColor,
          ),
          _TabContent(
            item: tabs[1],
            isActive: activeIndex == 1,
            onTap: () => onTabSelected(1),
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            onActiveColor: onActiveColor,
          ),
          SizedBox(width: profileButtonSize + centerGap),
          _TabContent(
            item: tabs[2],
            isActive: activeIndex == 2,
            onTap: () => onTabSelected(2),
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            onActiveColor: onActiveColor,
          ),
          _TabContent(
            item: tabs[3],
            isActive: activeIndex == 3,
            onTap: () => onTabSelected(3),
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            onActiveColor: onActiveColor,
          ),
        ],
      ),
    );

    final barContents = LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final gap = profileButtonSize + centerGap;
        final tabW = (w - gap) / 4;
        final pillW = tabW * 0.88;
        final pillH = barHeight * 0.88;
        final topOffset = (barHeight - pillH) / 2;

        final centers = <double>[
          tabW * 0.5,
          tabW * 1.5,
          2 * tabW + gap + tabW * 0.5,
          3 * tabW + gap + tabW * 0.5,
        ];

        final clampedIndex = activeIndex == null ? -1 : activeIndex.clamp(0, 3);
        final leftPos = clampedIndex < 0 ? -1000.0 : centers[clampedIndex] - pillW / 2;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(end: leftPos),
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
              builder: (context, animatedLeft, _) {
                return Positioned(
                  left: animatedLeft,
                  top: topOffset,
                  width: pillW,
                  height: pillH,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: activeColor,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned.fill(child: tabRow),
          ],
        );
      },
    );

    final barContainer = SizedBox(height: barHeight, child: barContents);

    final barWidget = isGlass
        ? GlassContainer(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            height: barHeight,
            settings: RecommendedGlassSettings.forBottomBar(brightness),
            shape: const LiquidRoundedSuperellipse(borderRadius: 28),
            child: barContainer,
          )
        : Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                width: 0.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: barContainer,
          );

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: SizedBox(
          height: 96,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: barWidget,
              ),
              Positioned(
                top: 0,
                child: ProfileButton(size: profileButtonSize),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  final NavTabItem item;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;
  final Color onActiveColor;

  const _TabContent({
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
    required this.onActiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                key: ValueKey(isActive),
                size: 24,
                color: isActive ? onActiveColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 240),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? onActiveColor : inactiveColor,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
