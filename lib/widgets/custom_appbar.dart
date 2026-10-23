import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:isc_notes/l10n/app_localizations.dart';
import 'package:isc_notes/utils/app_navigator.dart';
import 'package:isc_notes/utils/theme_extension.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final bool? showTitle;
  final Widget? title;
  final bool? centerTitle;
  final bool? showActions;
  final List<Widget>? actions;
  final bool? showLeading;
  final Widget? leading;

  const CustomAppbar({
    super.key,
    this.showTitle = true,
    this.title,
    this.centerTitle,
    this.showActions = true,
    this.actions,
    this.showLeading = true,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: showTitle == true
          ? title ??
                Text(
                  AppLocalizations.of(context)!.iscNotes,
                  style: TextStyle(
                    color: context.themeValue(
                      light: FlexThemeData.light().textTheme.bodyLarge!.color!,
                      dark: FlexThemeData.dark().textTheme.bodyLarge!.color!,
                    ),
                  ),
                )
          : null,
      centerTitle: centerTitle ?? false,
      backgroundColor: context.themeValue(
        light: FlexThemeData.light().scaffoldBackgroundColor,
        dark: FlexThemeData.dark().scaffoldBackgroundColor,
      ),
      leading: showLeading == true
          ? leading ??
                IconButton(
                  onPressed: AppNavigator.pop,
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: context.themeValue(
                      light: FlexThemeData.light().iconTheme.color,
                      dark: FlexThemeData.dark().iconTheme.color,
                    ),
                  ),
                )
          : null,
      actions: showActions == true ? actions : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
