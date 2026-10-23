import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme(FlexScheme scheme) => FlexThemeData.light(
    scheme: scheme,
    fontFamily: 'Poppins',
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
  );

  static ThemeData darkTheme(FlexScheme scheme) => FlexThemeData.dark(
    scheme: scheme,
    fontFamily: 'Poppins',
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
  );

  // Kullanılabilir şemaların listesi
  static final List<FlexScheme> availableSchemes = [
    FlexScheme.material,
    FlexScheme.materialHc,
    FlexScheme.blue,
    FlexScheme.indigo,
    FlexScheme.hippieBlue,
    FlexScheme.aquaBlue,
    FlexScheme.brandBlue,
    FlexScheme.deepBlue,
    FlexScheme.sakura,
    FlexScheme.mandyRed,
    FlexScheme.red,
    FlexScheme.redWine,
    FlexScheme.purpleBrown,
    FlexScheme.green,
    FlexScheme.money,
    FlexScheme.jungle,
    FlexScheme.greys,
    FlexScheme.blueWhale,
    FlexScheme.sanJuanBlue,
    FlexScheme.rosewood,
    FlexScheme.blumineBlue,
    FlexScheme.flutterDash,
    FlexScheme.materialBaseline,
    FlexScheme.verdunHemlock,
    FlexScheme.dellGenoa,
    FlexScheme.redM3,
    FlexScheme.pinkM3,
    FlexScheme.purpleM3,
    FlexScheme.indigoM3,
    FlexScheme.blueM3,
    FlexScheme.cyanM3,
    FlexScheme.tealM3,
    FlexScheme.greenM3,
    FlexScheme.limeM3,
    FlexScheme.yellowM3,
    FlexScheme.orangeM3,
    FlexScheme.deepOrangeM3,
  ];

  static String getSchemeDisplayName(FlexScheme scheme) {
    return scheme.name
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim();
  }
}
