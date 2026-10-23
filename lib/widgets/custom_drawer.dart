import 'package:flutter/material.dart';
import 'package:isc_notes/l10n/app_localizations.dart';
import 'package:isc_notes/utils/app_navigator.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.notes_rounded,
                  text: AppLocalizations.of(context)!.notes,
                  route: '/home',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.category_rounded,
                  text: AppLocalizations.of(context)!.categories,
                  route: '/categoryManager',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.delete_rounded,
                  text: AppLocalizations.of(context)!.recycleBin,
                  route: '/recycleBin',
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_rounded,
                  text: AppLocalizations.of(context)!.settings,
                  route: '/settings',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline_rounded,
                  text: AppLocalizations.of(context)!.iscNotesAbout,
                  route: '/about',
                ),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  // HEADER
  Widget _buildHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade900, Colors.teal.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(5, 5),
                    blurRadius: 3,
                    color: Colors.teal.shade900,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 38.0,
                backgroundImage: AssetImage("assets/images/app_logo.png"),
              ),
            ),

            SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.iscNotes,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Innovative Software Company',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // DRAWER ITEM
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required String route,
  }) {
    final theme = Theme.of(context);
    final isSelected = ModalRoute.of(context)?.settings.name == route;

    return Center(
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? theme.colorScheme.primary : null,
        ),
        title: Text(
          text,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.textTheme.bodyLarge!.color,
          ),
        ),
        selected: isSelected,
        onTap: () {
          AppNavigator.pop(); // Drawer'ı kapat
          if (route == "/about") {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Center(
                    child: Text(AppLocalizations.of(context)!.iscNotesAbout),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("v0.1.0 \n© ISC 2025", textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Text(
                        "Berat ARPA\nberatarpa@hotmail.com\nwww.beratarpa.com",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.close),
                    ),
                  ],
                );
              },
            );
          } else if (!isSelected) {
            AppNavigator.pushNamed(route);
          }
        },
      ),
    );
  }

  // FOOTER
  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        alignment: Alignment.center,
        child: Text(
          'v0.1.0 © ISC 2025',
          style: TextStyle(
            fontSize: 12,
            color: theme.hintColor.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
