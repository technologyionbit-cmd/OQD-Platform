import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/widgets/empty_state.dart';

/// A destination whose real feature hasn't been built yet (Phase 5 is
/// navigation-only). Still a real `Scaffold` with a real title — not a
/// blank screen — so the shell reads as an intentional, in-progress
/// product rather than a broken link. Swapped out screen-by-screen as each
/// feature phase lands; nothing else needs to change when that happens
/// since the route just points at a different builder.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, required this.icon, required this.message});

  final String title;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(icon: icon, message: message),
    );
  }
}
