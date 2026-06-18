import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../providers/navigation_provider.dart';
import '../providers/profile_provider.dart';
import '../constants/glass_settings.dart';
import '../data/models/meal_log.dart';
import '../data/models/reaction.dart';
import '../providers/meal_log_provider.dart';
import '../providers/reaction_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/summary_provider.dart';
import '../screens/today_screen.dart';
import '../theme/theme_style.dart';
import '../utils/progress_colors.dart';
import '../widgets/adaptive_widgets.dart';
import '../widgets/meal_photo_preview.dart';

class _MonthlyMealArgs {
  final int profileId;
  final int year;
  final int month;

  const _MonthlyMealArgs({
    required this.profileId,
    required this.year,
    required this.month,
  });

  @override
  bool operator ==(Object other) =>
      other is _MonthlyMealArgs &&
      other.profileId == profileId &&
      other.year == year &&
      other.month == month;

  @override
  int get hashCode => Object.hash(profileId, year, month);
}

final _monthlyMealCountsProvider =
    FutureProvider.family<Map<String, int>, _MonthlyMealArgs>(
        (ref, args) async {
  final repo = ref.read(repositoryProvider);
  final firstDay = DateTime(args.year, args.month, 1);
  final lastDay = DateTime(args.year, args.month + 1, 0);
  final fmt = DateFormat('yyyy-MM-dd');
  final meals = await repo.getMealLogsByDateRange(
      args.profileId, fmt.format(firstDay), fmt.format(lastDay));
  final mainMeals = meals.where((m) => m.mealType != 'Colaciones').toList();
  final counts = <String, Set<String>>{};
  for (final meal in mainMeals) {
    counts.putIfAbsent(meal.date, () => {}).add(meal.mealType);
  }
  return counts.map((k, v) => MapEntry(k, v.length));
});

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  int _slideKey = 0;

  void _prevMonth(DateTime selectedDate) {
    setState(() => _slideKey--);
    final prev = DateTime(selectedDate.year, selectedDate.month - 1, 1);
    ref.read(selectedDateProvider.notifier).state =
        DateFormat('yyyy-MM-dd').format(prev);
  }

  void _nextMonth(DateTime selectedDate) {
    setState(() => _slideKey++);
    final next = DateTime(selectedDate.year, selectedDate.month + 1, 1);
    ref.read(selectedDateProvider.notifier).state =
        DateFormat('yyyy-MM-dd').format(next);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateStr = ref.watch(selectedDateProvider);
    final activeId = ref.watch(activeProfileIdProvider);
    final isGlass = ref.watch(themeStyleProvider) == ThemeStyle.liquidGlass;
    final includeDinner = ref.watch(mealIncludeDinnerProvider);
    final mealTypesPerDay = includeDinner ? 4 : 3;

    final selectedDate = DateTime.parse(selectedDateStr);
    final now = DateTime.now();
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;
    final prevMonthLastDay =
        DateTime(selectedDate.year, selectedDate.month, 0).day;

    final monthKey = ValueKey('${selectedDate.year}-${selectedDate.month}');
    final theme = Theme.of(context);
    const dayHeaders = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];

    final mealCountsAsync = activeId != null
        ? ref.watch(_monthlyMealCountsProvider(_MonthlyMealArgs(
            profileId: activeId,
            year: selectedDate.year,
            month: selectedDate.month,
          )))
        : null;
    final mealCounts = mealCountsAsync?.maybeWhen(
        data: (m) => m, orElse: () => <String, int>{}) ?? <String, int>{};

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final direction = _slideKey < 0 ? -1.0 : 1.0;
                  final slide = Tween<Offset>(
                    begin: Offset(direction * 0.3, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: animation, curve: Curves.easeOutCubic));
                  return FadeTransition(
                    opacity: animation,
                    child:
                        SlideTransition(position: slide, child: child),
                  );
                },
                child: _CalendarCard(
                  key: monthKey,
                  isGlass: isGlass,
                  theme: theme,
                  header: Row(
                    children: [
                      _NavButton(
                        icon: CupertinoIcons.chevron_left,
                        onTap: () => _prevMonth(selectedDate),
                        isGlass: isGlass,
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            final slideAnim = Tween<Offset>(
                              begin: const Offset(0, 0.15),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic));
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                  position: slideAnim, child: child),
                            );
                          },
                          child: Text(
                            key: monthKey,
                            DateFormat('MMMM yyyy', 'es')
                                .format(selectedDate)
                                .replaceFirstMapped(RegExp(r'^[a-z]'),
                                    (m) => m[0]!.toUpperCase()),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                      _NavButton(
                        icon: CupertinoIcons.chevron_right,
                        onTap: () => _nextMonth(selectedDate),
                        isGlass: isGlass,
                      ),
                    ],
                  ),
                  dayHeaders: Row(
                    children: dayHeaders
                        .map((d) => Expanded(
                              child: Text(
                                d,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  grid: Column(
                    children: List.generate(
                      ((lastDay.day + startWeekday) / 7).ceil(),
                      (weekIndex) => Row(
                        children: List.generate(7, (dayIndex) {
                          final offset =
                              weekIndex * 7 + dayIndex - startWeekday;
                          int day;
                          bool isOtherMonth;
                          String dateStr;

                          if (offset < 0) {
                            // Previous month overflow
                            day = prevMonthLastDay + offset + 1;
                            isOtherMonth = true;
                            final pmYear = selectedDate.month == 1
                                ? selectedDate.year - 1
                                : selectedDate.year;
                            final pm = selectedDate.month == 1
                                ? 12
                                : selectedDate.month - 1;
                            dateStr =
                                '$pmYear-${pm.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                          } else if (offset >= lastDay.day) {
                            // Next month overflow
                            day = offset - lastDay.day + 1;
                            isOtherMonth = true;
                            final nmYear = selectedDate.month == 12
                                ? selectedDate.year + 1
                                : selectedDate.year;
                            final nm = selectedDate.month == 12
                                ? 1
                                : selectedDate.month + 1;
                            dateStr =
                                '$nmYear-${nm.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                          } else {
                            day = offset + 1;
                            isOtherMonth = false;
                            dateStr =
                                '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                          }

                          final isSelected = dateStr == selectedDateStr;
                          final isToday = dateStr ==
                              DateFormat('yyyy-MM-dd').format(now);

                          return Expanded(
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: _DayCell(
                                day: day,
                                dateStr: dateStr,
                                isSelected: isSelected,
                                isToday: isToday,
                                isOtherMonth: isOtherMonth,
                                activeId: activeId,
                                mealCount: mealCounts[dateStr] ?? 0,
                                mealTypesPerDay: mealTypesPerDay,
                                onTap: () {
                                  ref
                                      .read(selectedDateProvider.notifier)
                                      .state = dateStr;
                                },
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (activeId != null)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.08),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic)),
                        child: child,
                      ),
                    );
                  },
                  child: _DayDetails(
                    key: ValueKey(selectedDateStr),
                    profileId: activeId,
                    date: selectedDateStr,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  final Widget header;
  final Widget dayHeaders;
  final Widget grid;
  final bool isGlass;
  final ThemeData theme;

  const _CalendarCard({
    super.key,
    required this.header,
    required this.dayHeaders,
    required this.grid,
    required this.isGlass,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
          child: header,
        ),
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: dayHeaders,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: grid,
        ),
      ],
    );

    if (isGlass) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GlassCard(
          padding: EdgeInsets.zero,
          settings:
              RecommendedGlassSettings.forCard(theme.brightness),
          child: body,
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
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
      child: body,
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isGlass;

  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.isGlass,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isGlass) {
      return GlassButton(
        icon: Icon(icon),
        onTap: onTap,
        width: 44,
        height: 44,
        iconSize: 18,
        glowColor: Colors.transparent,
        shape: const LiquidRoundedSuperellipse(borderRadius: 22),
      );
    }
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        splashRadius: 22,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _DayCell extends ConsumerWidget {
  final int day;
  final String dateStr;
  final bool isSelected;
  final bool isToday;
  final bool isOtherMonth;
  final int? activeId;
  final int mealCount;
  final int mealTypesPerDay;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.dateStr,
    required this.isSelected,
    required this.isToday,
    required this.isOtherMonth,
    required this.activeId,
    required this.mealCount,
    required this.mealTypesPerDay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final error = theme.colorScheme.error;
    final onSurface = theme.colorScheme.onSurface;

    final hasReaction = activeId != null &&
        ref
            .watch(
                reactionsByDateProvider(ReactionDateArgs(activeId!, dateStr)))
            .maybeWhen(
                data: (r) => r.isNotEmpty, orElse: () => false);

    Color numberColor;
    if (isSelected) {
      numberColor = CupertinoColors.white;
    } else if (isOtherMonth) {
      numberColor =
          theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.35);
    } else if (isToday) {
      numberColor = primary;
    } else {
      numberColor = onSurface;
    }

    return GestureDetector(
      onTap: isOtherMonth ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Selected filled circle (red if reaction, teal otherwise)
          if (isSelected)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: hasReaction ? error : primary,
                shape: BoxShape.circle,
                border: Border.all(color: hasReaction ? error : primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: (hasReaction ? error : primary).withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          // Today (not selected): teal outline only, transparent fill
          if (isToday && !isSelected)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: primary, width: 1.5),
              ),
            ),
          // Reaction red outline (only when not selected — selected already has filled circle)
          if (hasReaction && !isSelected && !isOtherMonth)
            Transform.translate(
              offset: isToday ? const Offset(-2, -2) : Offset.zero,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: error, width: 1.5),
                ),
              ),
            ),
          Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: (isSelected || isToday)
                    ? FontWeight.w700
                    : FontWeight.w400,
                color: numberColor,
              ),
            ),
          ),
          // Meal count dot at bottom
          if (mealCount > 0 && !isOtherMonth)
            Positioned(
              bottom: 2,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: progressColor(mealCount / mealTypesPerDay),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayDetails extends ConsumerStatefulWidget {
  final int profileId;
  final String date;

  const _DayDetails({super.key, required this.profileId, required this.date});

  @override
  ConsumerState<_DayDetails> createState() => _DayDetailsState();
}

class _DayDetailsState extends ConsumerState<_DayDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _staggerCtrl.forward();
    });
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync =
        ref.watch(mealLogsByDateProvider(DateProfileArgs(widget.profileId, widget.date)));
    final reactionsAsync =
        ref.watch(reactionsByDateProvider(ReactionDateArgs(widget.profileId, widget.date)));

    final parsedDate = DateTime.parse(widget.date);
    final dayStr = parsedDate.day.toString();
    final monthStr = DateFormat('MMMM', 'es').format(parsedDate);
    final yearStr = parsedDate.year.toString();
    final title = 'Detalles del $dayStr de $monthStr de $yearStr';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 4),
        _buildStaggeredButton(),
        const SizedBox(height: 4),
        logsAsync.when(
          data: (logs) {
            final reactions =
                reactionsAsync.maybeWhen(data: (r) => r, orElse: () => <Reaction>[]);

            final grouped = <String, List<MealLog>>{};
            for (final log in logs) {
              grouped.putIfAbsent(log.mealType, () => []).add(log);
            }

            final entries = grouped.entries.toList();
            return Column(
              children: [
                if (logs.isEmpty)
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _staggerCtrl,
                      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                    ),
                    child: AdaptiveCard(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 100),
                        child: Center(
                          child: Text(
                            'Sin registros para este día',
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                for (int i = 0; i < entries.length; i++)
                  _buildStaggeredCard(i, entries[i], reactions),
              ],
            );
          },
          loading: () => const Center(child: AdaptiveProgress()),
          error: (_, _) => const Text('Error al cargar'),
        ),
      ],
    );
  }

  Widget _buildStaggeredCard(int index, MapEntry<String, List<MealLog>> entry,
      List<Reaction> reactions) {
    final mealType = entry.key;
    final mealLogs = entry.value;
    final reaction = reactions.where((r) => r.mealType == mealType).firstOrNull;
    final hasReaction = reaction != null;

    return AnimatedBuilder(
      animation: _staggerCtrl,
      builder: (context, child) {
        final animValue = CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(index * 0.15, 1.0, curve: Curves.easeOutCubic),
        ).value;
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animValue)),
            child: child,
          ),
        );
      },
      child: AdaptiveCard(
        margin: const EdgeInsets.symmetric(vertical: 6),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        borderColor:
            hasReaction ? Theme.of(context).colorScheme.error.withValues(alpha: 0.4) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_mealIcons[mealType] ?? Icons.restaurant,
                    color: Theme.of(context).colorScheme.primary, size: 22),
                const SizedBox(width: 10),
                Text(
                  mealType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  _mealRangeFor(mealType),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...mealLogs.map((log) {
              final timeStr = log.loggedAt != null
                  ? TimeOfDay.fromDateTime(log.loggedAt!)
                      .format(context)
                  : null;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 10,
                        color: log.hasReaction
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          log.foodItemsText,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (timeStr != null) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.schedule,
                            size: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
            if (reaction != null && reaction.symptoms.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 16, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        reaction.symptoms
                            .split(',')
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .join(', '),
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            PhotoInlinePreview(
              profileId: widget.profileId,
              date: widget.date,
              mealType: mealType,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaggeredButton() {
    return AnimatedBuilder(
      animation: _staggerCtrl,
      builder: (context, child) {
        final animValue = CurvedAnimation(
          parent: _staggerCtrl,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
        ).value;
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - animValue)),
            child: child,
          ),
        );
      },
      child: _EditDayButton(profileId: widget.profileId, date: widget.date),
    );
  }

  static const _mealIcons = {
    'Desayuno': Icons.free_breakfast,
    'Almuerzo': Icons.lunch_dining,
    'Once': Icons.coffee,
    'Cena': Icons.dinner_dining,
    'Colaciones': Icons.cookie_outlined,
  };

  String _mealRangeFor(String mealType) {
    if (mealType == 'Colaciones') return 'Sin Horario';
    final schedule = ref.watch(mealScheduleProvider);
    return schedule.forMeal(mealType).formatLabel();
  }
}

class _EditDayButton extends ConsumerWidget {
  final int profileId;
  final String date;

  const _EditDayButton({required this.profileId, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGlassLocal =
        ref.watch(themeStyleProvider) == ThemeStyle.liquidGlass;
    if (!_isPastDate(date)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Center(
        child: AdaptiveFilledButton(
          onTap: () =>
              _openEditDayModal(context, ref, profileId, date),
          height: 48,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_calendar,
                  size: 20,
                  color: isGlassLocal ? CupertinoColors.white : null),
              const SizedBox(width: 10),
              const Text('Editar día',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isPastDate(String dateStr) {
  final date = DateTime.parse(dateStr);
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  return date.isBefore(todayStart);
}

Future<void> _openEditDayModal(
    BuildContext context, WidgetRef ref, int profileId, String date) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => ProviderScope(
        overrides: [
          selectedDateProvider.overrideWith((ref) => date),
          activeInputTextProvider
              .overrideWith((ref) => InputTextNotifier()),
          mealLogNotifierProvider.overrideWith(MealLogNotifier.new),
          reactionNotifierProvider.overrideWith(ReactionNotifier.new),
        ],
        child: const TodayScreen(),
      ),
    ),
  );
  ref.invalidate(
      mealLogsByDateProvider(DateProfileArgs(profileId, date)));
  ref.invalidate(
      reactionsByDateProvider(ReactionDateArgs(profileId, date)));
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  final fromStr =
      '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  final toStr = DateFormat('yyyy-MM-dd').format(now);
  ref.invalidate(mealLogsByDateRangeProvider(
      DateRangeArgs(profileId: profileId, from: fromStr, to: toStr)));
  ref.invalidate(reactionsByDateRangeProvider(
      ReactionDateRangeArgs(profileId: profileId, from: fromStr, to: toStr)));
  ref.invalidate(weeklySummaryProvider(profileId));
}
