import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/utils/responsive.dart';

/// The one bottom-nav shell every authenticated role uses — client, lawyer,
/// and company each pass their own [destinations]/branches, but none of
/// them re-implements this chrome. Below [ResponsiveBreakpoints.tabletMin]
/// it's a bottom `NavigationBar` (matches the screenshots); at tablet/
/// desktop widths it switches to a side `NavigationRail` instead of
/// squeezing a bottom bar across a wide screen.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell, required this.destinations, this.banner});

  final StatefulNavigationShell navigationShell;
  final List<NavigationDestination> destinations;

  /// Optional strip kept visible under every tab (e.g. an account notice).
  /// Sits at the bottom, above the navigation bar, so it never competes
  /// with the screens' own app bars for the status-bar inset.
  final Widget? banner;

  @override
  Widget build(BuildContext context) {
    if (!context.isTabletOrWider) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (banner case final banner?) banner,
            NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _goBranch,
              destinations: destinations,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
            labelType: NavigationRailLabelType.all,
            destinations: [
              for (final destination in destinations)
                NavigationRailDestination(icon: destination.icon, selectedIcon: destination.selectedIcon, label: Text(destination.label)),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                Expanded(child: navigationShell),
                if (banner case final banner?) SafeArea(top: false, child: banner),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goBranch(int index) {
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }
}
