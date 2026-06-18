import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/pdf_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/option_toggle_row.dart';
import '../widgets/adaptive_button.dart';
import '../widgets/adaptive_widgets.dart';
import '../utils/pdf_generator.dart';
import '../utils/date_utils.dart';

class ExportPdfScreen extends ConsumerStatefulWidget {
  const ExportPdfScreen({super.key});

  @override
  ConsumerState<ExportPdfScreen> createState() => _ExportPdfScreenState();
}

class _ExportPdfScreenState extends ConsumerState<ExportPdfScreen> {
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 7));
    _fromCtrl.text = DateFormat('yyyy-MM-dd').format(from);
    _toCtrl.text = DateFormat('yyyy-MM-dd').format(now);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(pdfFromDateProvider.notifier).state = _fromCtrl.text;
      ref.read(pdfToDateProvider.notifier).state = _toCtrl.text;
    });
  }

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController target) async {
    final initial = DateTime.tryParse(target.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    final formatted = DateFormat('yyyy-MM-dd').format(picked);
    target.text = formatted;
    if (target == _fromCtrl) {
      ref.read(pdfFromDateProvider.notifier).state = formatted;
    } else {
      ref.read(pdfToDateProvider.notifier).state = formatted;
    }
  }

  void _applyPreset(int days) {
    final now = DateTime.now();
    final from = now.subtract(Duration(days: days));
    final f = DateFormat('yyyy-MM-dd').format(from);
    final t = DateFormat('yyyy-MM-dd').format(now);
    _fromCtrl.text = f;
    _toCtrl.text = t;
    ref.read(pdfFromDateProvider.notifier).state = f;
    ref.read(pdfToDateProvider.notifier).state = t;
  }

  void _applyMonthPreset() {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1);
    final f = DateFormat('yyyy-MM-dd').format(from);
    final t = DateFormat('yyyy-MM-dd').format(now);
    _fromCtrl.text = f;
    _toCtrl.text = t;
    ref.read(pdfFromDateProvider.notifier).state = f;
    ref.read(pdfToDateProvider.notifier).state = t;
  }

  void _applyThreeMonthsPreset() {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month - 3, now.day);
    final f = DateFormat('yyyy-MM-dd').format(from);
    final t = DateFormat('yyyy-MM-dd').format(now);
    _fromCtrl.text = f;
    _toCtrl.text = t;
    ref.read(pdfFromDateProvider.notifier).state = f;
    ref.read(pdfToDateProvider.notifier).state = t;
  }

  Future<void> _generate() async {
    if (_busy) return;
    final activeId = ref.read(activeProfileIdProvider);
    if (activeId == null) {
      AdaptiveToast.show(context,
          message: 'No hay perfil activo',
          variant: AdaptiveToastVariant.warning);
      return;
    }
    final from = _fromCtrl.text.trim();
    final to = _toCtrl.text.trim();
    if (from.isEmpty || to.isEmpty) {
      AdaptiveToast.show(context,
          message: 'Selecciona el rango de fechas',
          variant: AdaptiveToastVariant.warning);
      return;
    }
    if (from.compareTo(to) > 0) {
      AdaptiveToast.show(context,
          message: 'La fecha "Desde" debe ser anterior a "Hasta"',
          variant: AdaptiveToastVariant.warning);
      return;
    }
    final includeMeals = ref.read(pdfIncludeMealsProvider);
    final includeReactions = ref.read(pdfIncludeReactionsProvider);
    final includeNotes = ref.read(pdfIncludeNotesProvider);

    if (!includeMeals && !includeReactions && !includeNotes) {
      AdaptiveToast.show(context,
          message: 'Selecciona al menos una sección',
          variant: AdaptiveToastVariant.warning);
      return;
    }

    setState(() => _busy = true);
    try {
      final repo = ref.read(repositoryProvider);
      final profile = await repo.getProfileById(activeId);
      if (profile == null) {
        throw Exception('Perfil no encontrado');
      }
      final allMeals = await repo.getMealLogsByProfileId(activeId);
      final reactions = await repo.getReactionsByDateRange(activeId, from, to);

      await PdfGenerator().generate(
        firstName: profile.firstName,
        lastName: profile.lastName,
        category: profile.category,
        fromDate: from,
        toDate: to,
        mealLogs: allMeals,
        reactions: reactions,
        includeMeals: includeMeals,
        includeReactions: includeReactions,
        includeNotes: includeNotes,
      );
      if (!mounted) return;
      AdaptiveToast.show(context,
          message: 'PDF generado correctamente');
    } catch (e) {
      if (!mounted) return;
      AdaptiveToast.show(context,
          message: 'Error al generar PDF: $e',
          variant: AdaptiveToastVariant.destructive);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fromDate = ref.watch(pdfFromDateProvider);
    final toDate = ref.watch(pdfToDateProvider);
    final includeMeals = ref.watch(pdfIncludeMealsProvider);
    final includeReactions = ref.watch(pdfIncludeReactionsProvider);
    final includeNotes = ref.watch(pdfIncludeNotesProvider);

    if (_fromCtrl.text != fromDate && fromDate.isNotEmpty) {
      _fromCtrl.text = fromDate;
    }
    if (_toCtrl.text != toDate && toDate.isNotEmpty) {
      _toCtrl.text = toDate;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AbsorbPointer(
        absorbing: _busy,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: _busy
                              ? null
                              : () => ref
                                  .read(currentScreenProvider.notifier)
                                  .state = KeComoScreen.settings,
                          icon: const Icon(Icons.arrow_back),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Exportar PDF',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Selecciona el rango de fechas y las opciones para generar '
                      'un reporte PDF con el historial de consumo.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AdaptiveCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rango de Fecha',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _pickDate(_fromCtrl),
                                  behavior: HitTestBehavior.opaque,
                                  child: AbsorbPointer(
                                    child: AdaptiveTextField(
                                      controller: _fromCtrl,
                                      placeholder: 'Desde (yyyy-MM-dd)',
                                      prefixIcon: const Icon(
                                          Icons.calendar_today,
                                          size: 18),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _pickDate(_toCtrl),
                                  behavior: HitTestBehavior.opaque,
                                  child: AbsorbPointer(
                                    child: AdaptiveTextField(
                                      controller: _toCtrl,
                                      placeholder: 'Hasta (yyyy-MM-dd)',
                                      prefixIcon: const Icon(
                                          Icons.calendar_today,
                                          size: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (fromDate.isNotEmpty && toDate.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Rango: ${formatDate(fromDate)} — ${formatDate(toDate)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _DatePreset(
                                label: '7 días',
                                onTap: () => _applyPreset(7),
                              ),
                              const SizedBox(width: 8),
                              _DatePreset(
                                label: 'Este Mes',
                                onTap: _applyMonthPreset,
                              ),
                              const SizedBox(width: 8),
                        _DatePreset(
                          label: '3 Meses',
                          onTap: _applyThreeMonthsPreset,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
                    const SizedBox(height: 12),
                    AdaptiveCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: const Text(
                              'Opciones de Reporte',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OptionToggleRow(
                            title: 'Comidas',
                            value: includeMeals,
                            onChanged: (v) => ref
                                .read(pdfIncludeMealsProvider.notifier)
                                .state = v,
                          ),
                          OptionToggleRow(
                            title: 'Síntomas / Reacciones',
                            value: includeReactions,
                            onChanged: (v) => ref
                                .read(pdfIncludeReactionsProvider.notifier)
                                .state = v,
                          ),
                          OptionToggleRow(
                            title: 'Notas',
                            value: includeNotes,
                            onChanged: (v) => ref
                                .read(pdfIncludeNotesProvider.notifier)
                                .state = v,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: AdaptiveButton(
                        height: 52,
                        onTap: _busy ? null : _generate,
                        child: _busy
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white),
                                  ),
                                  SizedBox(width: 10),
                                  Text('Generando…',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700)),
                                ],
                              )
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.picture_as_pdf_outlined,
                                      size: 20),
                                  SizedBox(width: 8),
                                  Text('Generar PDF de Reporte',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePreset extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DatePreset({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AdaptiveButton(
        variant: AdaptiveButtonVariant.secondary,
        onTap: onTap,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
