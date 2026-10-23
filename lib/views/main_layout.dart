import 'package:flutter/material.dart';
import 'package:isc_notes/widgets/custom_appbar.dart';
import 'package:isc_notes/widgets/custom_drawer.dart';

class MainLayoutView extends StatefulWidget {
  final Widget body;
  final Widget? title;
  final CustomAppbar? appBar;
  final bool showAppBar;
  final bool showDrawer;
  final Widget? floatingActionButton;

  const MainLayoutView({
    super.key,
    required this.body,
    this.title,
    this.appBar,
    this.showAppBar = true,
    this.showDrawer = true,
    this.floatingActionButton,
  });

  @override
  State<MainLayoutView> createState() => _MainLayoutViewState();
}

class _MainLayoutViewState extends State<MainLayoutView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? (widget.appBar ?? CustomAppbar(title: widget.title))
          : null,
      body: SafeArea(child: widget.body),
      drawer: widget.showDrawer ? CustomDrawer() : null,
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
