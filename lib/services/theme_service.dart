import 'dart:ui';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:isc_notes/models/enums/app_theme_mode.dart';
import 'package:isc_notes/utils/app_storage.dart';
import 'package:isc_notes/viewmodels/base_viewmodel.dart';

class ThemeService extends BaseViewModel {
  static AppThemeMode _currentThemeMode = AppThemeMode.light;
  static AppThemeMode get currentThemeMode => _currentThemeMode;

  AppThemeMode _themeMode = AppThemeMode.light;
  AppThemeMode get themeMode => _themeMode;

  FlexScheme _colorScheme = FlexScheme.tealM3;
  FlexScheme get colorScheme => _colorScheme;

  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  Future<void> loadTheme() async {
    final themeString = AppStorage.getString(AppStorage.themeKey);
    if (themeString != null) {
      _themeMode = AppThemeMode.values.firstWhere(
        (mode) => mode.name == themeString,
        orElse: () => AppThemeMode.light,
      );
      _currentThemeMode = _themeMode;
    } else {
      // Sistem temasını al
      final brightness = PlatformDispatcher.instance.platformBrightness;
      _themeMode = brightness == Brightness.dark
          ? AppThemeMode.dark
          : AppThemeMode.light;
      _currentThemeMode = _themeMode;
      // İlk yükleme için kaydet
      await AppStorage.setString(AppStorage.themeKey, _themeMode.name);
    }

    final schemeString = AppStorage.getString(AppStorage.colorSchemeKey);
    _colorScheme = FlexScheme.values.firstWhere(
      (scheme) => scheme.name == schemeString,
      orElse: () => FlexScheme.tealM3,
    );
    notifyListeners();
  }

  Future<void> setTheme(AppThemeMode mode) async {
    _themeMode = mode;
    _currentThemeMode = mode;
    await AppStorage.setString(AppStorage.themeKey, mode.name);
    notifyListeners();
  }

  Future<void> setColorScheme(FlexScheme scheme) async {
    _colorScheme = scheme;
    await AppStorage.setString(AppStorage.colorSchemeKey, scheme.name);
    notifyListeners();
  }
}
