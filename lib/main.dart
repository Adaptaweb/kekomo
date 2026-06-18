import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'app.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  await initializeDateFormatting('es', null);
  Intl.defaultLocale = 'es';
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ),
  );
  runApp(
    LiquidGlassWidgets.wrap(
      theme: GlassThemeData(
        light: GlassThemeVariant.light.copyWith(
          glowColors: const GlassGlowColors(
            primary: AppColors.androidLightPrimary,
            success: AppColors.androidLightPrimary,
            info: AppColors.lightPrimary,
            warning: Color(0xFFFF9F0A),
            danger: Color(0xFFFF3B30),
          ),
        ),
        dark: GlassThemeVariant.dark.copyWith(
          glowColors: const GlassGlowColors(
            primary: AppColors.androidDarkPrimary,
            success: AppColors.androidDarkPrimary,
            info: AppColors.darkPrimary,
            warning: Color(0xFFFFD60A),
            danger: Color(0xFFFF453A),
          ),
        ),
      ),
      child: const ProviderScope(
        child: KeComoApp(),
      ),
    ),
  );
}
