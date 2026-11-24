import 'package:flutter/material.dart';

import 'package:aqd_admin/core/layout/layout_providers.dart';
import 'package:aqd_admin/core/layout/sidebar.dart';
import 'package:aqd_admin/core/layout/top_bar.dart';

/// Frame around every signed-in screen: sidebar (a drawer on narrow
/// screens), top bar with breadcrumbs, and the routed [child].
class AdminShell extends StatelessWidget {
  const AdminShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= drawerBreakpoint;

    final body = Column(
      children: [
        Builder(
          builder: (context) => TopBar(
            location: location,
            onMenuPressed: wide ? null : () => Scaffold.of(context).openDrawer(),
          ),
        ),
        Expanded(
          child: Padding(padding: const EdgeInsets.all(24), child: child),
        ),
      ],
    );

    return Scaffold(
      drawer: wide
          ? null
          : Drawer(
              width: sidebarWidth,
              child: Builder(
                builder: (context) => Sidebar(
                  currentLocation: location,
                  collapsible: false,
                  onNavigate: () => Navigator.of(context).pop(),
                ),
              ),
            ),
      body: Row(
        children: [
          if (wide) Sidebar(currentLocation: location),
          Expanded(child: body),
        ],
      ),
    );
  }
}
