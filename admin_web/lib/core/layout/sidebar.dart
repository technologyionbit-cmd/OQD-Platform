import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_admin/core/layout/layout_providers.dart';
import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/routing/nav_items.dart';
import 'package:aqd_admin/core/theme/app_colors.dart';
import 'package:aqd_admin/features/auth/presentation/providers/auth_controller.dart';

const double sidebarWidth = 264;
const double sidebarCollapsedWidth = 72;

/// The navy navigation column. [collapsible] is false inside the drawer,
/// where folding it makes no sense.
class Sidebar extends ConsumerWidget {
  const Sidebar({
    required this.currentLocation,
    super.key,
    this.collapsible = true,
    this.onNavigate,
  });

  final String currentLocation;
  final bool collapsible;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final collapsed = collapsible && ref.watch(sidebarCollapsedProvider);
    final active = navItemFor(currentLocation);
    final items = navItemsFor(ref.watch(authControllerProvider).value);
    final target = collapsed ? sidebarCollapsedWidth : sidebarWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: target,
      color: AppColors.navy,
      clipBehavior: Clip.hardEdge,
      // Content is laid out at the final width while the container animates,
      // so nothing overflows mid-fold; the container just clips it.
      child: OverflowBox(
        alignment: AlignmentDirectional.topStart,
        minWidth: target,
        maxWidth: target,
        child: Column(
          children: [
            SizedBox(
              height: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.balance, color: Colors.white),
                    if (!collapsed) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.appName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Divider(color: AppColors.navyLight),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                children: [
                  for (final item in items)
                    _NavTile(
                      item: item,
                      selected: item == active,
                      collapsed: collapsed,
                      label: item.label(l10n),
                      onTap: () {
                        onNavigate?.call();
                        context.go(item.path);
                      },
                    ),
                ],
              ),
            ),
            if (collapsible) ...[
              const Divider(color: AppColors.navyLight),
              Tooltip(
                message: collapsed ? l10n.expandSidebar : l10n.collapseSidebar,
                child: InkWell(
                  onTap:
                      () =>
                          ref.read(sidebarCollapsedProvider.notifier).toggle(),
                  child: SizedBox(
                    height: 48,
                    child: Row(
                      mainAxisAlignment:
                          collapsed
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                      children: [
                        if (!collapsed) const SizedBox(width: 20),
                        Icon(
                          collapsed
                              ? Icons.keyboard_double_arrow_right
                              : Icons.keyboard_double_arrow_left,
                          color: Colors.white70,
                        ),
                        if (!collapsed) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.collapseSidebar,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.selected,
    required this.collapsed,
    required this.label,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final bool collapsed;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tile = Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 0 : 12,
            vertical: 12,
          ),
          child: Row(
            mainAxisAlignment:
                collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(
                item.icon,
                size: 22,
                color: selected ? Colors.white : Colors.white70,
              ),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white70,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: collapsed ? Tooltip(message: label, child: tile) : tile,
    );
  }
}
