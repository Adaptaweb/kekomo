import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/theme_style.dart';
import '../widgets/settings_toggle_row.dart';
import '../widgets/settings_action_row.dart';
import '../widgets/meal_settings_card.dart';
import '../widgets/adaptive_widgets.dart';
import '../widgets/leading_icon_box.dart';
import '../widgets/profile_sheet.dart';
import '../widgets/profile_summary_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(settingsNotifierProvider.notifier).loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeSettingProvider);
    final reminders = ref.watch(remindersEnabledProvider);
    final safetyAlerts = ref.watch(safetyAlertsEnabledProvider);

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
                child: const Text(
                  'Ajustes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const ProfileSummaryCard(),
              const SizedBox(height: 4),
              const _SectionHeader(title: 'CONFIGURACIÓN DE COMIDAS'),
              const SizedBox(height: 8),
              const MealSettingsCard(),
              const SizedBox(height: 4),
              const _SectionHeader(title: 'PREFERENCIAS'),
              AdaptiveGroupedSection(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                children: [
                  SettingsToggleRow(
                    icon: Icons.notifications,
                    title: 'Recordatorios',
                    value: reminders,
                    onChanged: (v) => ref
                        .read(settingsNotifierProvider.notifier)
                        .updateReminders(v),
                  ),
                  SettingsToggleRow(
                    icon: Icons.security,
                    title: 'Alertas de Seguridad',
                    value: safetyAlerts,
                    onChanged: (v) => ref
                        .read(settingsNotifierProvider.notifier)
                        .updateSafetyAlerts(v),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const _SectionHeader(title: 'APARIENCIA'),
              AdaptiveGroupedSection(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                children: [
                  _ThemeModeSelector(
                    selected: themeMode,
                    onChanged: (mode) => ref
                        .read(settingsNotifierProvider.notifier)
                        .updateThemeMode(mode),
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const _SectionHeader(title: 'DATOS'),
              AdaptiveGroupedSection(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                children: [
                  SettingsActionRow(
                    icon: Icons.picture_as_pdf,
                    title: 'Exportar mis Datos',
                    onTap: () => ref
                        .read(currentScreenProvider.notifier)
                        .state = KeComoScreen.exportPdf,
                  ),
                  SettingsActionRow(
                    icon: Icons.privacy_tip,
                    title: 'Política de Privacidad',
                    onTap: () => AdaptiveToast.showInfo(context,
                        message: 'Política de Privacidad'),
                  ),
                  SettingsActionRow(
                    icon: Icons.switch_account,
                    title: 'Cambiar Perfil',
                    onTap: () => showProfileSheet(context, ref),
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'KECOMO V2.4.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final ThemeModeSetting selected;
  final ValueChanged<ThemeModeSetting> onChanged;
  final bool isLast;

  const _ThemeModeSelector({
    required this.selected,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return AdaptiveSwitchListTile(
      leading: LeadingIconBox(icon: Icons.dark_mode, color: color),
      title: const Text(
        'Modo oscuro',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      value: selected == ThemeModeSetting.dark,
      onChanged: (v) => onChanged(
        v ? ThemeModeSetting.dark : ThemeModeSetting.light,
      ),
      isLast: isLast,
    );
  }
}
