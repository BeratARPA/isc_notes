import 'dart:ui';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:isc_notes/models/enums/app_theme_mode.dart';
import 'package:isc_notes/services/localization_service.dart';
import 'package:isc_notes/services/theme_service.dart';
import 'package:isc_notes/utils/app_storage.dart';
import 'package:isc_notes/viewmodels/base_viewmodel.dart';

class SettingsViewModel extends BaseViewModel {
  final ThemeService themeService;
  final LocalizationService localizationService;

  SettingsViewModel(this.themeService, this.localizationService) {
    _loadSettings();
  }

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  String _languageCode = 'en';
  String get languageCode => _languageCode;

  FlexScheme _colorScheme = FlexScheme.tealM3;
  FlexScheme get colorScheme => _colorScheme;

  Future<void> _loadSettings() async {
    _isDarkMode = themeService.themeMode == AppThemeMode.dark;
    _languageCode = localizationService.locale?.languageCode ?? 'en';

    final schemeString = AppStorage.getString(AppStorage.colorSchemeKey);
    _colorScheme = FlexScheme.values.firstWhere(
      (scheme) => scheme.name == schemeString,
      orElse: () => FlexScheme.tealM3,
    );

    notifyListeners();
  }

  void setLanguageCode(String code) {
    _languageCode = code;
    localizationService.setLocale(Locale(code));
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    themeService.setTheme(_isDarkMode ? AppThemeMode.dark : AppThemeMode.light);
    notifyListeners();
  }

  void setColorScheme(FlexScheme scheme) {
    _colorScheme = scheme;
    themeService.setColorScheme(scheme);
    notifyListeners();
  }
}
