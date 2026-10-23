import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:isc_notes/l10n/app_localizations.dart';
import 'package:isc_notes/utils/app_theme.dart';
import 'package:isc_notes/viewmodels/settings_viewmodel.dart';
import 'package:isc_notes/views/main_layout.dart';
import 'package:isc_notes/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return MainLayoutView(
      appBar: CustomAppbar(
        title: Text(AppLocalizations.of(context)!.settings),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ListTile(
            title: Text(AppLocalizations.of(context)!.theme),
            trailing: Switch(
              value: Provider.of<SettingsViewModel>(context).isDarkMode,
              onChanged: (value) {
                Provider.of<SettingsViewModel>(
                  context,
                  listen: false,
                ).toggleDarkMode();
              },
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.language),
            trailing: DropdownButton<String>(
              value: Provider.of<SettingsViewModel>(context).languageCode,
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Text(AppLocalizations.of(context)!.english),
                ),
                DropdownMenuItem(
                  value: 'tr',
                  child: Text(AppLocalizations.of(context)!.turkish),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  Provider.of<SettingsViewModel>(
                    context,
                    listen: false,
                  ).setLanguageCode(newValue);
                }
              },
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.colorScheme),
            trailing: DropdownButton<FlexScheme>(
              value: Provider.of<SettingsViewModel>(context).colorScheme,
              items: AppTheme.availableSchemes.map((scheme) {
                final colors = FlexSchemeColor.from(
                  primary: FlexColor.schemes[scheme]!.light.primary,
                  secondary: FlexColor.schemes[scheme]!.light.secondary,
                );
                return DropdownMenuItem(
                  value: scheme,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: colors.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(AppTheme.getSchemeDisplayName(scheme)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (FlexScheme? newScheme) {
                if (newScheme != null) {
                  Provider.of<SettingsViewModel>(
                    context,
                    listen: false,
                  ).setColorScheme(newScheme);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
