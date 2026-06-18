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
      activeIcon: CupertinoIcons.calendar,
      label: 'Calendario',
    ),
    NavTabItem(
      icon: CupertinoIcons.chart_bar_alt_fill,
      activeIcon: CupertinoIcons.chart_bar_square_fill,
      label: 'Resumen',
    ),
    NavTabItem(
      icon: CupertinoIcons.gear,
      activeIcon: CupertinoIcons.gear_solid,
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

  static const _inactiveIcon = Color(0xFF9CA3AF);
  static const _inactiveLabel = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final activeColor = theme.colorScheme.primary;

    const barHeight = 72.0;
    const centerGap = 8.0;
    const pillSize = 68.0;

    final activeIndex = currentIndex;

    final tabRow = Row(
      children: [
        for (int i = 0; i < tabs.length; i++) ...[
          if (i == 2) SizedBox(width: profileButtonSize + centerGap),
          Expanded(
            child: _TabContent(
              item: tabs[i],
              isActive: activeIndex == i,
              onTap: () => onTabSelected(i),
              activeColor: activeColor,
              inactiveIconColor: _inactiveIcon,
              inactiveLabelColor: _inactiveLabel,
            ),
          ),
        ],
      ],
    );

    final barContents = LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final gap = profileButtonSize + centerGap;
        final tabW = (w - gap) / 4;

        final centers = <double>[
          tabW * 0.5,
          tabW * 1.5,
          2 * tabW + gap + tabW * 0.5,
          3 * tabW + gap + tabW * 0.5,
        ];

        final clampedIndex = activeIndex == null ? -1 : activeIndex.clamp(0, 3);
        final leftPos =
            clampedIndex < 0 ? -1000.0 : centers[clampedIndex] - pillSize / 2;
        final pillTopOffset = (barHeight - pillSize) / 2;

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
                  top: pillTopOffset,
                  width: pillSize,
                  height: pillSize,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: activeColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.30),
                            blurRadius: 12,
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
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 15,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: barContainer,
          );

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: SizedBox(
          height: barHeight + 24,
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
  final Color inactiveIconColor;
  final Color inactiveLabelColor;

  const _TabContent({
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
    required this.inactiveIconColor,
    required this.inactiveLabelColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
              size: 22,
              color: isActive ? Colors.white : inactiveIconColor,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 240),
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? Colors.white : inactiveLabelColor,
            ),
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
