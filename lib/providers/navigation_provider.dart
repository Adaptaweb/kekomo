import 'package:flutter_riverpod/flutter_riverpod.dart';

enum KeComoScreen {
  onboarding,
  welcome,
  today,
  calendar,
  summary,
  settings,
  exportPdf,
}

final currentScreenProvider =
    StateProvider<KeComoScreen>((ref) => KeComoScreen.onboarding);

final selectedDateProvider = StateProvider<String>((ref) {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
});

/// Permite a las pantallas recalcular la fecha de "hoy" cuando
/// han estado abiertas mucho rato (ej. cambió la medianoche).
void refreshTodayDate(Ref ref) {
  final now = DateTime.now();
  final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  final current = ref.read(selectedDateProvider);
  if (current == today) return;
  ref.read(selectedDateProvider.notifier).state = today;
}
