import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ThemeStyle {
  liquidGlass,
  materialSolid,
}

enum ThemeModeSetting {
  light,
  dark,
  system;

  ThemeMode get flutterThemeMode {
    switch (this) {
      case ThemeModeSetting.light:
        return ThemeMode.light;
      case ThemeModeSetting.dark:
        return ThemeMode.dark;
      case ThemeModeSetting.system:
        return ThemeMode.system;
    }
  }
}

final themeStyleProvider =
    StateProvider<ThemeStyle>((ref) => ThemeStyle.materialSolid);

final themeModeSettingProvider =
    StateProvider<ThemeModeSetting>((ref) => ThemeModeSetting.light);
