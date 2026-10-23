import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:isc_notes/utils/theme_extension.dart';
import 'package:isc_notes/views/category_manager_screen.dart';
import 'package:isc_notes/views/home_screen.dart';
import 'package:isc_notes/views/note_editor_screen.dart';
import 'package:isc_notes/views/recycle_bin_screen.dart';
import 'package:isc_notes/views/settings_screen.dart';

class AppNavigator {
  static Map<String, Widget Function(BuildContext)> routes = {
    "/home": (context) => const HomeScreen(),
    "/noteEditor": (context) => const NoteEditorScreen(),
    "/categoryManager": (context) => const CategoryManagerScreen(),
    "/recycleBin": (context) => const RecycleBinScreen(),
    "/settings": (context) => const SettingsScreen(),
  };

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static bool get canPop => navigatorKey.currentState!.canPop();

  static Future<T?> push<T extends Object?>(Route<T> route) {
    return navigatorKey.currentState!.push(route);
  }

  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  static void pop<T extends Object?>([T? result]) {
    return navigatorKey.currentState!.pop(result);
  }

  static void popUntil(bool Function(Route<dynamic>) predicate) {
    navigatorKey.currentState!.popUntil(predicate);
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  static Future<T?> showDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: navigatorKey.currentContext!,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context!).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) => builder(ctx),
    );
  }

  static Future<T?> pushFullscreenDialog<T>(Widget page) {
    return push<T>(
      MaterialPageRoute<T>(builder: (_) => page, fullscreenDialog: true),
    );
  }

  static void showSnack(String message) {
    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        backgroundColor: context!.themeValue(
          light: FlexThemeData.light().scaffoldBackgroundColor,
          dark: FlexThemeData.dark().scaffoldBackgroundColor,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
        content: Text(
          message,
          style: TextStyle(
            color: context!.themeValue(
              light: FlexThemeData.light().textTheme.bodyLarge!.color!,
              dark: FlexThemeData.dark().textTheme.bodyLarge!.color!,
            ),
          ),
        ),
      ),
    );
  }

  static void clearSnackbars() {
    ScaffoldMessenger.of(context!).clearSnackBars();
  }
}
