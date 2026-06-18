import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/meal_schedule.dart';
import '../data/models/setting.dart';
import '../theme/theme_style.dart';
import 'profile_provider.dart';

final allSettingsProvider = FutureProvider((ref) async {
  final repo = ref.read(repositoryProvider);
  return repo.getAllSettings();
});

final mealConfigProvider = StateProvider<String>((ref) => 'Ambos');
final darkModeProvider = StateProvider<bool>((ref) => false);
final remindersEnabledProvider = StateProvider<bool>((ref) => true);
final safetyAlertsEnabledProvider = StateProvider<bool>((ref) => true);

final mealIncludeDinnerProvider = StateProvider<bool>((ref) => true);
final mealScheduleProvider =
    StateProvider<MealSchedule>((ref) => MealSchedule.defaultSchedule());

class SettingsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> loadSettings() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(repositoryProvider);
      final settings = await repo.getAllSettings();
      for (final s in settings) {
        try {
          await _applySetting(s);
        } catch (e, st) {
          // Si un setting específico falla (ej. JSON corrupto del
          // schedule), seguimos con el resto. Sólo registramos.
          developer.log(
            'SettingsNotifier: fallo al aplicar setting ${s.key}',
            error: e,
            stackTrace: st,
            name: 'kekomo.settings',
          );
        }
      }
    });
  }

  Future<void> _applySetting(Setting s) async {
    switch (s.key) {
      case 'meal_config':
        ref.read(mealConfigProvider.notifier).state = s.value;
        break;
      case 'dark_mode':
        ref.read(darkModeProvider.notifier).state = s.value == 'true';
        break;
      case 'theme_mode':
        ref.read(themeModeSettingProvider.notifier).state =
            _parseThemeMode(s.value);
        ref.read(darkModeProvider.notifier).state = s.value == 'dark';
        break;
      case 'theme_style':
        ref.read(themeStyleProvider.notifier).state =
            _parseThemeStyle(s.value);
        break;
      case 'reminders_enabled':
        ref.read(remindersEnabledProvider.notifier).state = s.value == 'true';
        break;
      case 'safety_alerts_enabled':
        ref.read(safetyAlertsEnabledProvider.notifier).state =
            s.value == 'true';
        break;
      case 'meal_include_dinner':
        ref.read(mealIncludeDinnerProvider.notifier).state = s.value == 'true';
        break;
      case 'meal_schedule':
        final decoded = jsonDecode(s.value);
        if (decoded is Map<String, dynamic>) {
          ref.read(mealScheduleProvider.notifier).state =
              MealSchedule.fromJson(decoded);
        } else {
          throw FormatException(
            'meal_schedule no es un objeto JSON: ${decoded.runtimeType}',
          );
        }
        break;
    }
  }

  Future<void> updateMealConfig(String value) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      ref.read(mealConfigProvider.notifier).state = value;
      await _persist('meal_config', value);
    });
  }

  Future<void> updateDarkMode(bool value) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      ref.read(darkModeProvider.notifier).state = value;
      await _persist('dark_mode', value.toString());
    });
  }

  Future<void> updateThemeMode(ThemeModeSetting mode) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      ref.read(themeModeSettingProvider.notifier).state = mode;
      final value = mode == ThemeModeSetting.dark
          ? 'dark'
          : mode == ThemeModeSetting.light
              ? 'light'
              : 'system';
      await _persist('theme_mode', value);
      ref.read(darkModeProvider.notifier).state = mode == ThemeModeSetting.dark;
    });
  }

  Future<void> updateThemeStyle(ThemeStyle style) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      ref.read(themeStyleProvider.notifier).state = style;
      await _persist('theme_style',
          style == ThemeStyle.liquidGlass ? 'liquid_glass' : 'material_solid');
    });
  }

  Future<void> updateReminders(bool value) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      ref.read(remindersEnabledProvider.notifier).state = value;
      await _persist('reminders_enabled', value.toString());
    });
  }

  Future<void> updateSafetyAlerts(bool value) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      ref.read(safetyAlertsEnabledProvider.notifier).state = value;
      await _persist('safety_alerts_enabled', value.toString());
    });
  }

  Future<void> updateMealIncludeDinner(bool value) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      ref.read(mealIncludeDinnerProvider.notifier).state = value;
      await _persist('meal_include_dinner', value.toString());
    });
  }

  Future<void> updateMealSchedule(MealSchedule schedule) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      ref.read(mealScheduleProvider.notifier).state = schedule;
      await _persist('meal_schedule', jsonEncode(schedule.toJson()));
    });
  }

  Future<void> _persist(String key, String value) async {
    final repo = ref.read(repositoryProvider);
    await repo.insertSetting(Setting(key: key, value: value));
    ref.invalidate(allSettingsProvider);
  }

  ThemeModeSetting _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeModeSetting.light;
      case 'dark':
        return ThemeModeSetting.dark;
      default:
        return ThemeModeSetting.system;
    }
  }

  ThemeStyle _parseThemeStyle(String value) {
    if (value == 'liquid_glass') return ThemeStyle.liquidGlass;
    return ThemeStyle.materialSolid;
  }
}

final settingsNotifierProvider =
    AsyncNotifierProvider<SettingsNotifier, void>(SettingsNotifier.new);
