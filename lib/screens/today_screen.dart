import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/glass_settings.dart';
import '../providers/navigation_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/meal_log_provider.dart';
import '../providers/reaction_provider.dart';
import '../providers/settings_provider.dart';
import '../data/models/meal_log.dart';
import '../theme/theme_style.dart';
import '../widgets/adaptive_widgets.dart';
import '../widgets/meal_time_picker_sheet.dart';
import '../widgets/meal_photo_preview.dart';
import '../widgets/progress_card.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  String? _expandedMealType;

  @override
  void initState() {
    super.initState();
    _expandedMealType = _resolveCurrentMealType();
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
    final theme = Theme.of(context);
    final activeId = ref.watch(activeProfileIdProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final includeDinner = ref.watch(mealIncludeDinnerProvider);
    final mealTypes = _getMealTypes(includeDinner);
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final currentMealType = _resolveCurrentMealType();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (selectedDate == todayStr)
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                            height: 1.1,
                            color: const Color(0xFF0F172A),
                          ),
                          children: [
                            const TextSpan(text: 'Mi '),
                            TextSpan(
                              text: 'Registro',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const TextSpan(text: ' Diario'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      )
                    else
                      Text(
                        'Editando: $selectedDate',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      selectedDate == todayStr
                          ? DateFormat("d 'de' MMMM", 'es').format(now)
                          : _formatDate(selectedDate),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (activeId != null) ...[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final mealType = mealTypes[index];
                    final staggerStart = index * 0.12;
                    return AnimatedBuilder(
                      animation: _staggerCtrl,
                      builder: (context, child) {
                        final animValue = CurvedAnimation(
                          parent: _staggerCtrl,
                          curve: Interval(staggerStart, 1.0,
                              curve: Curves.easeOutCubic),
                        ).value;
                        return Opacity(
                          opacity: animValue,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - animValue)),
                            child: child,
                          ),
                        );
                      },
                      child: _MealCard(
                        profileId: activeId,
                        date: selectedDate,
                        mealType: mealType,
                        isActive: selectedDate == todayStr && mealType == currentMealType,
                        isExpanded: mealType == _expandedMealType,
                        onToggle: () => setState(() {
                          _expandedMealType =
                              _expandedMealType == mealType ? null : mealType;
                        }),
                      ),
                    );
                  },
                  childCount: mealTypes.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _staggerCtrl,
                  builder: (context, child) {
                    final animValue = CurvedAnimation(
                      parent: _staggerCtrl,
                      curve: const Interval(0.5, 1.0,
                          curve: Curves.easeOutCubic),
                    ).value;
                    return Opacity(
                      opacity: animValue,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - animValue)),
                        child: child,
                      ),
                    );
                  },
                  child: _DailyProgressCard(
                      profileId: activeId,
                      date: selectedDate,
                      mealTypes: mealTypes),
                ),
              ),
            ] else
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Selecciona o crea un perfil'),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  String _resolveCurrentMealType() {
    final schedule = ref.read(mealScheduleProvider);
    final includeDinner = ref.read(mealIncludeDinnerProvider);
    final candidates = <String>[
      'Desayuno',
      'Almuerzo',
      'Once',
      if (includeDinner) 'Cena',
    ];
    final now = DateTime.now();
    for (final meal in candidates) {
      if (schedule.forMeal(meal).containsHourMinute(now.hour, now.minute)) {
        return meal;
      }
    }
    return 'Colaciones';
  }

  List<String> _getMealTypes(bool includeDinner) {
    final base = includeDinner
        ? ['Desayuno', 'Almuerzo', 'Once', 'Cena']
        : ['Desayuno', 'Almuerzo', 'Once'];
    return [...base, 'Colaciones'];
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat("d 'de' MMMM", 'es').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}

class _DailyProgressCard extends ConsumerWidget {
  final int profileId;
  final String date;
  final List<String> mealTypes;

  const _DailyProgressCard({
    required this.profileId,
    required this.date,
    required this.mealTypes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync =
        ref.watch(mealLogsByDateProvider(DateProfileArgs(profileId, date)));
    final reactionsAsync =
        ref.watch(reactionsByDateProvider(ReactionDateArgs(profileId, date)));
    final isGlass = ref.watch(themeStyleProvider) == ThemeStyle.liquidGlass;
    final theme = Theme.of(context);

    return logsAsync.when(
      data: (logs) {
        final primaryMealTypes =
            mealTypes.where((t) => t != 'Colaciones').toList();
        final loggedMeals = logs
            .where((l) => primaryMealTypes.contains(l.mealType))
            .map((l) => l.mealType)
            .toSet();
        final loggedCount = loggedMeals.length;
        final total = primaryMealTypes.length;
        final remaining = (total - loggedCount).clamp(0, total);
        final progress = total == 0 ? 0.0 : loggedCount / total;
        final percent = (progress * 100).round();

        final reactions = reactionsAsync.maybeWhen(
          data: (r) => r,
          orElse: () => const [],
        );
        final reactionCount = reactions.length;

        final accentPrimary = theme.colorScheme.primary;
        final accentDanger = theme.colorScheme.error;

        return ProgressCard(
          data: ProgressCardData(
            progress: progress,
            completionPercent: percent,
            statRows: [
              StatRowData(
                label: 'Comidas Registradas',
                value: '$loggedCount',
                color: accentPrimary,
              ),
              StatRowData(
                label: 'Pendientes hoy',
                value: '$remaining',
                color: accentDanger,
              ),
            ],
            metrics: [
              MetricData(
                label: 'Al día',
                value: '$loggedCount',
                max: '$total',
                barColor: accentPrimary,
                progress: progress,
              ),
              MetricData(
                label: 'Reacciones',
                value: '$reactionCount',
                barColor: accentDanger,
                progress: total == 0
                    ? 0.0
                    : (reactionCount / total).clamp(0.0, 1.0),
              ),
              MetricData(
                label: 'Alimentos',
                value: '${logs.length}',
                barColor: accentPrimary,
                progress: 1.0,
              ),
            ],
          ),
          isGlass: isGlass,
        );
      },
      loading: () => AdaptiveCard(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: const Center(child: AdaptiveProgress()),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _MealCard extends ConsumerStatefulWidget {
  final int profileId;
  final String date;
  final String mealType;
  final bool isActive;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _MealCard({
    required this.profileId,
    required this.date,
    required this.mealType,
    this.isActive = false,
    this.isExpanded = false,
    required this.onToggle,
  });

  @override
  ConsumerState<_MealCard> createState() => _MealCardState();
}

class _MealCardState extends ConsumerState<_MealCard> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final _picker = ImagePicker();
  final _saveRowKey = GlobalKey();

  static const _mealEmojis = {
    'Desayuno': '☕',
    'Almuerzo': '🍔',
    'Once': '☕',
    'Cena': '🍽️',
    'Colaciones': '🍪',
  };

  ({String emoji, String range}) _mealInfoFor(String meal) {
    if (meal == 'Colaciones') {
      return (emoji: _mealEmojis[meal]!, range: 'Sin Horario');
    }
    final schedule = ref.watch(mealScheduleProvider);
    final range = schedule.forMeal(meal).formatLabel();
    return (emoji: _mealEmojis[meal]!, range: range);
  }

  @override
  void initState() {
    super.initState();
    final saved = ref.read(activeInputTextProvider)[widget.mealType] ?? '';
    _textController.text = saved;
  }

  @override
  void didUpdateWidget(_MealCard oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  String _placeholderFor(String mealType) {
    return switch (mealType) {
      'Desayuno' => '¿Qué desayunaste hoy?',
      'Almuerzo' => '¿Qué almorzaste hoy?',
      'Cena' => '¿Qué cenaste hoy?',
      'Once' => '¿Qué comiste en la once?',
      _ => '¿Qué comiste hoy?',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = _mealInfoFor(widget.mealType);
    final logsAsync = ref.watch(
        mealLogsByDateProvider(DateProfileArgs(widget.profileId, widget.date)));
    final reactionsAsync = ref.watch(
        reactionsByDateProvider(ReactionDateArgs(widget.profileId, widget.date)));
    final isGlass = ref.watch(themeStyleProvider) == ThemeStyle.liquidGlass;
    final reaction = reactionsAsync.maybeWhen(
      data: (reactions) => reactions
          .where((r) => r.mealType == widget.mealType)
          .firstOrNull,
      orElse: () => null,
    );
    final hasReaction = reaction != null;
    final reactionSymptoms = (reaction?.symptoms ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(', ');
    final canSave = (ref.watch(activeInputTextProvider)[widget.mealType] ?? '').trim().length >= 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: AdaptiveCard(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          borderColor: hasReaction ? theme.colorScheme.error.withValues(alpha: 0.4) : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => widget.onToggle(),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            info.emoji,
                            style: const TextStyle(fontSize: 16, height: 1.0),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              widget.mealType,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (widget.isActive) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 224, 241, 215),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'AHORA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF475569),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          info.range,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: widget.isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity, height: 0),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        minLines: 4,
                        maxLines: 6,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          hintText: _placeholderFor(widget.mealType),
                          hintStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (v) {
                          ref
                              .read(activeInputTextProvider.notifier)
                              .update(widget.mealType, v);
                        },
                      ),
                      const SizedBox(height: 14),
                      // Fila: [CameraButton] [Miniatura + +N] — alineada a la izquierda
                      Row(
                        children: [
                          _CameraButton(
                            onTap: () => _showInputMethodSheet(context),
                            isGlass: isGlass,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: PhotoInlinePreview(
                              profileId: widget.profileId,
                              date: widget.date,
                              mealType: widget.mealType,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        key: _saveRowKey,
                        children: [
                          Expanded(
                            child: _ReactionButton(
                              hasReaction: hasReaction,
                              onTap: () => _triggerReaction(),
                              isGlass: isGlass,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SaveButton(
                              enabled: canSave,
                              onTap: () => _saveMealLog(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              logsAsync.when(
                 data: (logs) {
                   final filtered = logs
                       .where((l) => l.mealType == widget.mealType)
                       .toList();
                   final showSymptoms = hasReaction && reactionSymptoms.isNotEmpty;

                    if (filtered.isEmpty && !showSymptoms) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Center(
                          child: Text(
                            'No hay registros aún',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 13,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    }
                   return Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        if (filtered.isNotEmpty)
                          ...filtered
                              .map((log) => _LogItem(
                                    log: log,
                                    onEdit: () => _showEditDialog(log),
                                    onDelete: () => _deleteLog(log),
                                  )),
                       if (showSymptoms)
                         Container(
                           margin: const EdgeInsets.only(top: 8),
                           padding: const EdgeInsets.symmetric(
                               horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error
                                  .withValues(alpha: 0.08),
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: Row(
                             crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    size: 16, color: theme.colorScheme.error),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    reactionSymptoms,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.colorScheme.error,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                           ),
                         ),
                     ],
                   );
                 },
                 loading: () => const SizedBox.shrink(),
                 error: (_, _) => const SizedBox.shrink(),
               ),
            ],
          ),
          ),
        ),
    );
  }

  Future<void> _saveMealLog() async {
    try {
      await ref.read(mealLogNotifierProvider.notifier).saveMealLog(
            widget.profileId,
            widget.date,
            widget.mealType,
          );

      if (!mounted) return;
      AdaptiveToast.show(context, message: 'Guardado');
      setState(() {
        _textController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      AdaptiveToast.show(context,
          message: 'No se pudo guardar: $e',
          variant: AdaptiveToastVariant.destructive);
    }
  }

  void _triggerReaction() {
    ref.read(reactionNotifierProvider.notifier).triggerReactionPrompt(
          widget.profileId,
          widget.date,
          widget.mealType,
        );
    _showReactionDialog();
  }

  void _showReactionDialog() {
    final isGlass = ref.read(themeStyleProvider) == ThemeStyle.liquidGlass;
    final symptoms = [
      'Ronchas', 'Colicos', 'Picor de garganta', 'Hinchazon de labios',
      'Vomitos', 'Hipo', 'Heces con sangre',
    ];

    final isEditing =
        ref.read(reactionDialogSymptomsProvider).isNotEmpty ||
        ref.read(reactionDialogDescriptionProvider).isNotEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReactionSheetContent(
        profileId: widget.profileId,
        date: widget.date,
        mealType: widget.mealType,
        symptoms: symptoms,
        isEditing: isEditing,
        isGlass: isGlass,
      ),
    );
  }

  void _showEditDialog(MealLog log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditLogSheet(
        log: log,
        onSave: (newText) {
          final updated = log.copyWith(foodItemsText: newText);
          ref.read(mealLogNotifierProvider.notifier).updateMealLog(updated);
          if (mounted) {
            AdaptiveToast.show(
              context,
              message: 'Guardado',
            );
          }
        },
      ),
    );
  }

  void _deleteLog(MealLog log) {
    ref.read(mealLogNotifierProvider.notifier).deleteMealLog(log.id!, log.profileId, log.date);
    if (mounted) {
      AdaptiveToast.show(
        context,
        message: 'Eliminado',
        variant: AdaptiveToastVariant.destructive,
      );
    }
  }

  // ignore: unused_element
  // _addPhotoToLog eliminado: las fotos ahora son por sección (meal_photos),
  // no por alimento individual. Se reemplazó por _SectionPhotoStrip.

  void _showInputMethodSheet(BuildContext context) {
    AdaptiveActionSheet.show(
      context,
      title: 'Fotos de comida',
      options: [
        AdaptiveActionSheetOption(
          label: '📷 Tomar foto',
          onTap: () => _takePhoto(),
        ),
        AdaptiveActionSheetOption(
          label: '🖼️ Seleccionar de galería',
          onTap: () => _pickFromGallery(),
        ),
      ],
    );
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (photo != null) {
        final savedPath = await _savePhotoToAppDir(photo);
        await ref.read(mealLogNotifierProvider.notifier).addPhoto(
              widget.profileId,
              widget.date,
              widget.mealType,
              savedPath,
            );
      }
    } catch (e) {
      if (mounted) {
        AdaptiveToast.show(
          context,
          message: 'No se pudo tomar la foto',
          variant: AdaptiveToastVariant.warning,
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      final notifier = ref.read(mealLogNotifierProvider.notifier);
      for (final image in images) {
        final savedPath = await _savePhotoToAppDir(image);
        await notifier.addPhoto(
          widget.profileId,
          widget.date,
          widget.mealType,
          savedPath,
        );
      }
    } catch (e) {
      if (mounted) {
        AdaptiveToast.show(
          context,
          message: 'No se pudieron seleccionar las fotos',
          variant: AdaptiveToastVariant.warning,
        );
      }
    }
  }

  Future<String> _savePhotoToAppDir(XFile file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${appDir.path}/meal_photos');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final newPath = '${photosDir.path}/$fileName';
    await File(file.path).copy(newPath);
    return newPath;
  }
}

class _ReactionSheetContent extends ConsumerStatefulWidget {
  final int profileId;
  final String date;
  final String mealType;
  final List<String> symptoms;
  final bool isEditing;
  final bool isGlass;

  const _ReactionSheetContent({
    required this.profileId,
    required this.date,
    required this.mealType,
    required this.symptoms,
    required this.isEditing,
    required this.isGlass,
  });

  @override
  ConsumerState<_ReactionSheetContent> createState() =>
      _ReactionSheetContentState();
}

class _ReactionSheetContentState extends ConsumerState<_ReactionSheetContent> {
  final _focusDescription = FocusNode();
  final _scrollController = ScrollController();
  late final TextEditingController _descriptionCtrl;

  @override
  void initState() {
    super.initState();
    _descriptionCtrl = TextEditingController(
      text: ref.read(reactionDialogDescriptionProvider),
    );
    _focusDescription.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusDescription.removeListener(_onFocusChange);
    _focusDescription.dispose();
    _scrollController.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusDescription.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final profileId = widget.profileId;
    final date = widget.date;
    final mealType = widget.mealType;
    final symptoms = widget.symptoms;
    final isEditing = widget.isEditing;
    final isGlass = widget.isGlass;

    final sheetContent = Container(
      margin: EdgeInsets.only(
        bottom: bottomInset + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isGlass
            ? Colors.transparent
            : theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: isGlass
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, -4),
                ),
              ],
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                isEditing
                    ? 'Editar reacción alérgica'
                    : 'Registra reacción alérgica',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                isEditing
                    ? 'Modifica los síntomas registrados'
                    : 'Anota cualquier síntoma presentado para este día',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: theme.colorScheme.error, size: 22),
                  const SizedBox(width: 8),
                  const Text('Síntomas',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Consumer(
                builder: (context, ref, _) {
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: symptoms.map((symptom) {
                      final current =
                          ref.watch(reactionDialogSymptomsProvider);
                      final isSelected = current.contains(symptom);
                      return AdaptiveChip(
                        label: symptom,
                        onTap: () {
                          if (isSelected) {
                            ref
                                .read(
                                    reactionDialogSymptomsProvider.notifier)
                                .state = current
                                .replaceAll(', $symptom', '')
                                .replaceAll(symptom, '');
                          } else {
                            ref
                                .read(
                                    reactionDialogSymptomsProvider.notifier)
                                .state = '$current, $symptom';
                          }
                        },
                        backgroundColor: isSelected
                            ? theme.colorScheme.error
                                .withValues(alpha: 0.45)
                            : null,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AdaptiveDivider(),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AdaptiveTextField(
                controller: _descriptionCtrl,
                focusNode: _focusDescription,
                placeholder:
                    'Breve descripción de la reacción (opcional)',
                maxLines: 4,
                onChanged: (v) => ref
                    .read(reactionDialogDescriptionProvider.notifier)
                    .state = v,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  if (isEditing)
                    TextButton(
                      onPressed: () {
                        ref
                            .read(reactionNotifierProvider.notifier)
                            .deleteReaction(
                                profileId, date, mealType);
                        Navigator.pop(context);
                        AdaptiveToast.show(context,
                            message: 'Reacción eliminada',
                            variant: AdaptiveToastVariant.destructive);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                      child: const Text('Eliminar'),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  _buildSaveReactionButton(context, ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (isGlass) {
      return ClipRRect(
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
        child: GlassCard(
          settings:
              RecommendedGlassSettings.forCard(theme.brightness),
          child: sheetContent,
        ),
      );
    }
    return sheetContent;
  }

  Widget _buildSaveReactionButton(BuildContext context, WidgetRef ref) {
    Future<void> onTap() async {
      try {
        await ref.read(reactionNotifierProvider.notifier).confirmReaction(
              widget.profileId,
              widget.date,
            );
        if (!context.mounted) return;
        Navigator.pop(context);
        AdaptiveToast.show(context, message: 'Reacción registrada');
      } catch (e) {
        if (!context.mounted) return;
        AdaptiveToast.show(context,
            message: 'No se pudo guardar la reacción: $e',
            variant: AdaptiveToastVariant.destructive);
      }
    }

    if (widget.isGlass) {
      return GlassButton.custom(
        onTap: onTap,
        height: 44,
        style: GlassButtonStyle.prominent,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Guardar',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: CupertinoColors.white)),
        ),
      );
    }
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      child: const Text('Guardar',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }
}

class _CameraButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isGlass;

  const _CameraButton({
    required this.onTap,
    required this.isGlass,
  });

  @override
  Widget build(BuildContext context) {
    if (isGlass) {
      return GlassButton(
        icon: const Icon(Icons.camera_alt_outlined),
        onTap: onTap,
        width: 48,
        height: 48,
        iconSize: 22,
      );
    }
    return IconButton.filled(
      onPressed: onTap,
      icon: const Icon(Icons.camera_alt_outlined, size: 22),
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}


class _LogItem extends ConsumerWidget {
  final MealLog log;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LogItem({
    required this.log,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dotColor = log.hasReaction
        ? theme.colorScheme.tertiary
        : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _showActionSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFD1EAD9).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFD1EAD9).withValues(alpha: 0.6),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    log.foodItemsText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (log.loggedAt != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _pickAndSaveTime(context),
                    child: Text(
                      TimeOfDay.fromDateTime(log.loggedAt!).format(context),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _pickAndSaveTime(context),
                    child: const Text(
                      'Sin hora registrada',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogActionSheet(
        onEdit: () {
          Navigator.of(context).pop();
          onEdit();
        },
        onSetTime: () async {
          Navigator.of(context).pop();
          await _pickAndSaveTime(context);
        },
        onDelete: () {
          Navigator.of(context).pop();
          _confirmDelete(context);
        },
        foodItemsText: log.foodItemsText,
        hasTime: log.loggedAt != null,
      ),
    );
  }

  Future<void> _pickAndSaveTime(BuildContext context) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final initial = log.loggedAt != null
        ? TimeOfDay.fromDateTime(log.loggedAt!)
        : TimeOfDay.now();

    final picked = await showMealTimePicker(
      context,
      title: log.loggedAt != null ? 'Seleccionar hora' : 'Ingresar hora',
      initial: initial,
    );

    // null = usuario canceló explícitamente con el botón.
    if (picked == null) return;
    if (!context.mounted) return;

    final base = DateTime.parse(log.date);
    final newLoggedAt = DateTime(
      base.year,
      base.month,
      base.day,
      picked.hour,
      picked.minute,
    );
    final updated = log.copyWith(loggedAt: newLoggedAt);
    container.read(mealLogNotifierProvider.notifier).updateMealLog(updated);
    if (context.mounted) {
      AdaptiveToast.show(
        context,
        message: 'Hora actualizada',
      );
    }
  }

  void _confirmDelete(BuildContext context) {
    AdaptiveDialog.show(
      context: context,
      title: 'Eliminar registro',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      content: Text(
        '¿Estás seguro de que quieres eliminar "${log.foodItemsText}"?',
      ),
      actions: [
        AdaptiveDialogAction(
          label: 'Cancelar',
          onPressed: () => Navigator.pop(context),
        ),
        AdaptiveDialogAction(
          label: 'Eliminar',
          isPrimary: true,
          onPressed: () {
            onDelete();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class _LogActionSheet extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onSetTime;
  final VoidCallback onDelete;
  final String foodItemsText;
  final bool hasTime;

  const _LogActionSheet({
    required this.onEdit,
    required this.onSetTime,
    required this.onDelete,
    required this.foodItemsText,
    required this.hasTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                foodItemsText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            const AdaptiveDivider(),
            ListTile(
              leading: Icon(Icons.edit_outlined,
                  color: theme.colorScheme.primary),
              title: const Text('Editar'),
              onTap: onEdit,
            ),
            ListTile(
              leading: Icon(Icons.schedule,
                  color: theme.colorScheme.primary),
              title: Text(hasTime ? 'Seleccionar hora' : 'Ingresar hora'),
              onTap: onSetTime,
            ),
            ListTile(
              leading: Icon(Icons.delete_outline,
                  color: theme.colorScheme.error),
              title: Text('Eliminar',
                  style: TextStyle(color: theme.colorScheme.error)),
              onTap: onDelete,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _EditLogSheet extends StatefulWidget {
  final MealLog log;
  final void Function(String newText) onSave;

  const _EditLogSheet({
    required this.log,
    required this.onSave,
  });

  @override
  State<_EditLogSheet> createState() => _EditLogSheetState();
}

class _EditLogSheetState extends State<_EditLogSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.log.foodItemsText);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(_ctrl.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Editar comida',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              AdaptiveTextField(
                controller: _ctrl,
                placeholder: 'Comida',
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                        label: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: const BorderSide(
                              color: Color(0xFFE5E7EB),
                              width: 1.5,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _save,
                        icon: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          'Guardar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final bool hasReaction;
  final VoidCallback onTap;
  final bool isGlass;

  const _ReactionButton({
    required this.hasReaction,
    required this.onTap,
    required this.isGlass,
  });

  static const _red = Color(0xFFEF4444);
  static const _redBorder = Color(0xFFFEE2E2);

  @override
  Widget build(BuildContext context) {
    if (hasReaction) {
      return SizedBox(
        height: 48,
        child: Material(
          color: _red,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Reacción Registrada',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 48,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _redBorder, width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 18, color: _red),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Reacción',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends ConsumerWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _SaveButton({
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isGlass = ref.watch(themeStyleProvider) == ThemeStyle.liquidGlass;
    final bg = enabled
        ? theme.colorScheme.primary
        : const Color(0xFFE5E7EB);
    final fg = enabled ? Colors.white : const Color(0xFF9CA3AF);

    if (isGlass && enabled) {
      return SizedBox(
        height: 48,
        child: GlassButton.custom(
          onTap: onTap,
          style: GlassButtonStyle.prominent,
          shape: const LiquidRoundedSuperellipse(borderRadius: 16),
          height: 48,
          glowColor: theme.colorScheme.primary,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Guardar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 48,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              'Guardar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
