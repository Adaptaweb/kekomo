import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/navigation_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/summary_provider.dart';
import '../widgets/adaptive_button.dart';
import '../widgets/adaptive_widgets.dart';
import '../widgets/allergen_insight_item.dart';
import '../widgets/progress_card.dart';
import '../utils/progress_colors.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
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

  ({String from, String to, String display}) _weekDisplay() {
    final now = DateTime.now();
    final weekday = now.weekday;
    final monday = now.subtract(Duration(days: weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final es = DateFormat('d MMM', 'es');
    final yr = DateFormat('yyyy').format(monday);
    return (
      from: DateFormat('yyyy-MM-dd').format(monday),
      to: DateFormat('yyyy-MM-dd').format(sunday),
      display: '${es.format(monday)} — ${es.format(now)}, $yr',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeId = ref.watch(activeProfileIdProvider);
    final week = _weekDisplay();

    final summaryAsync =
        activeId != null ? ref.watch(weeklySummaryProvider(activeId)) : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 0, bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                          height: 1.1,
                          color: const Color(0xFF0F172A),
                        ),
                        children: [
                          const TextSpan(text: 'Resumen '),
                          TextSpan(
                            text: 'Semanal',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      week.display,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (activeId == null)
                _buildEmptyCard(theme)
              else if (summaryAsync == null)
                const Center(child: AdaptiveProgress())
              else
                summaryAsync.when(
                  data: (summary) =>
                      _buildContent(context, ref, theme, summary),
                  loading: () => const Center(child: AdaptiveProgress()),
                  error: (e, _) => _buildErrorCard(theme),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(ThemeData theme) {
    return _staggeredWidget(0, AdaptiveCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Text(
          'Selecciona o crea un perfil',
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ));
  }

  Widget _buildErrorCard(ThemeData theme) {
    return _staggeredWidget(0, AdaptiveCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text('Error al cargar resumen',
            style: TextStyle(color: theme.colorScheme.error)),
      ),
    ));
  }

  Widget _buildContent(
      BuildContext context,
      WidgetRef ref,
      ThemeData theme,
      WeeklySummary summary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _staggeredWidget(0, _buildChartCard(theme, summary)),
        const SizedBox(height: 8),
        _staggeredWidget(1, ProgressCard(
          data: ProgressCardData(
            progress: summary.totalSlotsToDate == 0
                ? 0.0
                : summary.totalLogged / summary.totalSlotsToDate,
            completionPercent: summary.completionPercent,
            statRows: [
              StatRowData(
                label: 'Comidas Registradas',
                value: '${summary.totalLogged}',
                color: theme.colorScheme.primary,
              ),
              StatRowData(
                label: 'Faltan esta semana',
                value: '${summary.pendingSlots}',
                color: theme.colorScheme.error,
              ),
            ],
            metrics: [
              MetricData(
                label: 'Al día',
                value: '${summary.totalLogged}',
                max: '${summary.totalSlotsToDate}',
                barColor: theme.colorScheme.primary,
                progress: summary.totalSlotsToDate == 0
                    ? 0.0
                    : summary.totalLogged / summary.totalSlotsToDate,
              ),
              MetricData(
                label: 'Reacciones',
                value: '${summary.reactionCount}',
                barColor: theme.colorScheme.error,
                progress: summary.totalSlotsToDate == 0
                    ? 0.0
                    : (summary.reactionCount / summary.totalSlotsToDate).clamp(0.0, 1.0),
              ),
              MetricData(
                label: 'Alérgenos',
                value: '${summary.allergenCount}',
                barColor: const Color(0xFFEAB308),
                progress: summary.allergenCount > 10
                    ? 1.0
                    : summary.allergenCount / 10,
              ),
            ],
          ),
        )),
        const SizedBox(height: 8),
        _staggeredWidget(2, _buildAnalysisCard(theme, summary)),
        const SizedBox(height: 8),
        _staggeredWidget(3, _buildExportButton(ref, theme)),
        const SizedBox(height: 8),
        _staggeredWidget(4, _buildTipCard(theme)),
      ],
    );
  }

  Widget _staggeredWidget(int index, Widget child) {
    return AnimatedBuilder(
      animation: _staggerCtrl,
      builder: (context, w) {
        final anim = CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic),
        ).value;
        return Opacity(
          opacity: anim,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - anim)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildChartCard(
      ThemeData theme, WeeklySummary summary) {
    final dayLabels = ['Lun', 'Mar', 'Mier', 'Jue', 'Vie', 'Sab', 'Dom'];
    final now = DateTime.now();
    final weekday = now.weekday;
    final todayIndex = weekday - 1;
    final values =
        List<int>.generate(7, (i) => summary.mealsByDay[i]?.length ?? 0);
    final maxVal = values.fold<int>(0, math.max);
    final maxDisplay = maxVal > 0 ? maxVal : 5;

    return AdaptiveCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Registro semanal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 24),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final value = values[i];
                final isToday = i == todayIndex;
                final isFuture = i > todayIndex;
                final heightFraction =
                    maxDisplay > 0 ? value / maxDisplay : 0.0;
                final barH = (88 * (heightFraction > 0 ? heightFraction : 0.06))
                    .clamp(6.0, 88.0);

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0.5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (value > 0 && !isFuture)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '$value',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isToday
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        Container(
                          height: barH,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isFuture
                                  ? [
                                      theme.colorScheme.outline.withValues(alpha: 0.1),
                                      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                    ]
                                  : _barGradientColors(value, summary.mealTypesPerDay),
                            ),
                            borderRadius:
                                const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dayLabels[i],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                            color: isFuture
                                ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                                : isToday
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(ThemeData theme, WeeklySummary summary) {
    final insights = summary.allergenInsights;
    return AdaptiveCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Análisis Inteligente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          if (insights.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                summary.allergenCount > 0
                    ? 'No se detectaron alérgenos de tu perfil en las comidas de esta semana.\nRevisa tus alérgenos en Configuración.'
                    : 'Agrega alérgenos en tu perfil para ver el análisis.',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...List.generate(insights.length, (i) {
              final insight = insights[i];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (i > 0) const SizedBox(height: 12),
                  AllergenInsightItem(
                    allergenName: insight.allergenName,
                    description: insight.description,
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildExportButton(WidgetRef ref, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: AdaptiveButton(
          onTap: () {
            ref.read(currentScreenProvider.notifier).state =
                KeComoScreen.exportPdf;
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.picture_as_pdf_outlined, size: 20),
              SizedBox(width: 8),
              Text('Exportar Reporte',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(ThemeData theme) {
    return AdaptiveCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFD1EAD9).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(CupertinoIcons.lightbulb,
                color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'La contaminación cruzada es común en panaderías. '
              'Siempre pregunta por los ingredientes al comer fuera.',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<Color> _barGradientColors(int value, int maxPerDay) {
  final p = maxPerDay > 0 ? value / maxPerDay : 0.0;
  final c = progressColor(p);
  return [c, c.withValues(alpha: 0.55)];
}
