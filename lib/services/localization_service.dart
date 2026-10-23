import 'dart:ui';
import 'package:isc_notes/utils/app_storage.dart';
import 'package:isc_notes/viewmodels/base_viewmodel.dart';

class LocalizationService extends BaseViewModel {
  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> loadLocale() async {
    final savedLocale = AppStorage.getString(AppStorage.localeKey);
    if (savedLocale != null) {
      _locale = Locale(savedLocale);
    } else {
      // Sistem dilini al
      final systemLocale = PlatformDispatcher.instance.locale;
      // Desteklenen diller arasında kontrol et (sadece tr ve en)
      if (systemLocale.languageCode == 'tr') {
        _locale = const Locale('tr');
      } else {
        _locale = const Locale('en');
        // Varsayılan
      }
      // İlk yükleme için kaydet
      await AppStorage.setString(AppStorage.localeKey, _locale!.languageCode);
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await AppStorage.setString(AppStorage.localeKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> clearLocale() async {
    _locale = null;
    await AppStorage.remove(AppStorage.localeKey);
    notifyListeners();
  }
}
