import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the desktop sidebar is folded down to icons.
class SidebarCollapsed extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final sidebarCollapsedProvider = NotifierProvider<SidebarCollapsed, bool>(SidebarCollapsed.new);

/// Below this width the sidebar becomes a drawer behind a menu button.
const double drawerBreakpoint = 900;
