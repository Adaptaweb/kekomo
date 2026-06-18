import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'constants/glass_settings.dart';
import 'providers/navigation_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';
import 'theme/theme_style.dart';
import 'widgets/animated_background.dart';
import 'widgets/custom_bottom_nav_bar.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/today_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/export_pdf_screen.dart';

class KeComoApp extends ConsumerWidget {
  const KeComoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGlass = ref.watch(themeStyleProvider) == ThemeStyle.liquidGlass;
    final themeMode = ref.watch(themeModeSettingProvider);

    return MaterialApp(
      title: 'KeComo',
      debugShowCheckedModeBanner: false,
      theme: isGlass ? AppTheme.lightTheme : AppTheme.materialLightTheme,
      darkTheme: isGlass ? AppTheme.darkTheme : AppTheme.materialDarkTheme,
      themeMode: themeMode.flutterThemeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],
      home: const _AppScaffold(),
    );
  }
}

class _AppScaffold extends ConsumerStatefulWidget {
  const _AppScaffold();

  @override
  ConsumerState<_AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<_AppScaffold> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialize();
    }
  }

  Future<void> _initialize() async {
    final repo = ref.read(repositoryProvider);
    final profiles = await repo.getAllProfiles();
    if (profiles.isNotEmpty && mounted) {
      ref.read(activeProfileIdProvider.notifier).state = profiles.first.id;
      ref.read(currentScreenProvider.notifier).state = KeComoScreen.today;
      ref.read(settingsNotifierProvider.notifier).loadSettings();
    }
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentScreen = ref.watch(currentScreenProvider);
    final activeProfileId = ref.watch(activeProfileIdProvider);
    final showNav = currentScreen != KeComoScreen.onboarding &&
        currentScreen != KeComoScreen.welcome;
    final isGlass = ref.watch(themeStyleProvider) == ThemeStyle.liquidGlass;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
    );
    final screens = [
      KeComoScreen.today,
      KeComoScreen.calendar,
      KeComoScreen.summary,
      KeComoScreen.settings,
    ];

    final currentIndex = currentScreen == KeComoScreen.today
        ? 0
        : currentScreen == KeComoScreen.calendar
            ? 1
            : currentScreen == KeComoScreen.summary
                ? 2
                : currentScreen == KeComoScreen.settings
                    ? 3
                    : null;

    final customBottomBar = showNav
        ? CustomBottomNavBar(
            currentIndex: currentIndex,
            isGlass: isGlass,
            onTabSelected: (i) {
              ref.read(currentScreenProvider.notifier).state = screens[i];
              if (screens[i] == KeComoScreen.today) {
                final now = DateTime.now();
                ref.read(selectedDateProvider.notifier).state =
                    '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
              }
            },
          )
        : const SizedBox.shrink();

    if (!_initialized) {
      return const SplashScreen();
    }

    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: KeyedSubtree(
        key: ValueKey('${currentScreen}_$activeProfileId'),
        child: _buildScreen(currentScreen),
      ),
    );

    if (isGlass) {
      return GlassScaffold(
        background: AppBackground(brightness: brightness),
        settings: RecommendedGlassSettings.forCard(brightness),
        edgeToEdge: true,
        topEdgeFade: true,
        bottomBarHeight: 112,
        bottomBar: showNav ? customBottomBar : null,
        body: body,
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: showNav ? customBottomBar : null,
    );
  }

  Widget _buildScreen(KeComoScreen screen) {
    switch (screen) {
      case KeComoScreen.onboarding:
        return const OnboardingScreen();
      case KeComoScreen.welcome:
        return const WelcomeScreen();
      case KeComoScreen.today:
        return const TodayScreen();
      case KeComoScreen.calendar:
        return const CalendarScreen();
      case KeComoScreen.summary:
        return const SummaryScreen();
      case KeComoScreen.settings:
        return const SettingsScreen();
      case KeComoScreen.exportPdf:
        return const ExportPdfScreen();
    }
  }
}
