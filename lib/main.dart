import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:isc_notes/database/app_database.dart';
import 'package:isc_notes/database/repositories/category_repository.dart';
import 'package:isc_notes/database/repositories/note_repository.dart';
import 'package:isc_notes/l10n/app_localizations.dart';
import 'package:isc_notes/services/localization_service.dart';
import 'package:isc_notes/services/theme_service.dart';
import 'package:isc_notes/utils/app_navigator.dart';
import 'package:isc_notes/utils/app_storage.dart';
import 'package:isc_notes/utils/app_theme.dart';
import 'package:isc_notes/viewmodels/category_manager_viewmodel.dart';
import 'package:isc_notes/viewmodels/home_viewmodel.dart';
import 'package:isc_notes/viewmodels/note_editor_viewmodel.dart';
import 'package:isc_notes/viewmodels/recycle_bin_viewmodel.dart';
import 'package:isc_notes/viewmodels/settings_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:isc_notes/l10n/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  SystemChrome.setApplicationSwitcherDescription(
    const ApplicationSwitcherDescription(
      label: 'ISC NOTES',
      primaryColor: 0xFF2196F3, // mavi
    ),
  );

  await AppStorage.init();

  final appDatabase = AppDatabase();

  final themeService = ThemeService();
  await themeService.loadTheme();

  final localizationService = LocalizationService();
  await localizationService.loadLocale();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => NoteRepository(appDatabase)),
        Provider(create: (context) => CategoryRepository(appDatabase)),
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: localizationService),
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(context.read(), context.read()),
        ),
        ChangeNotifierProvider(
          create: (context) => NoteEditorViewModel(context.read()),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoryManagerViewModel(context.read()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              RecycleBinViewModel(context.read(), context.read()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              SettingsViewModel(context.read(), context.read()),
        ),
      ],

      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final localizationService = Provider.of<LocalizationService>(context);

    return MaterialApp(
      title: "ISC NOTES",
      debugShowCheckedModeBanner: false,

      supportedLocales: l10n.all,
      locale: localizationService.locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],

      theme: AppTheme.lightTheme(themeService.colorScheme),
      darkTheme: AppTheme.darkTheme(themeService.colorScheme),
      themeMode: themeService.materialThemeMode,

      navigatorKey: AppNavigator.navigatorKey,
      initialRoute: "/home",
      routes: AppNavigator.routes,
    );
  }
}
