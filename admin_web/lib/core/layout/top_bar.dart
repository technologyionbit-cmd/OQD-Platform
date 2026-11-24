import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/layout/breadcrumbs.dart';
import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/localization/locale_controller.dart';
import 'package:aqd_admin/features/auth/presentation/providers/auth_controller.dart';

class TopBar extends ConsumerWidget implements PreferredSizeWidget {
  const TopBar({required this.location, super.key, this.onMenuPressed});

  final String location;

  /// Set when the sidebar is a drawer: shows the menu button.
  final VoidCallback? onMenuPressed;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final user = ref.watch(authControllerProvider).value;
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Material(
      color: scheme.surface,
      child: Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: scheme.outlineVariant))),
        child: Row(
          children: [
            if (onMenuPressed != null)
              IconButton(tooltip: l10n.openMenu, onPressed: onMenuPressed, icon: const Icon(Icons.menu)),
            Expanded(
              child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Breadcrumbs(location: location)),
            ),
            TextButton.icon(
              onPressed: () => ref.read(localeProvider.notifier).toggle(),
              icon: const Icon(Icons.language, size: 18),
              label: Text(isArabic ? l10n.switchToEnglish : l10n.switchToArabic),
            ),
            const SizedBox(width: 8),
            if (user != null)
              PopupMenuButton<String>(
                tooltip: user.fullName,
                onSelected: (value) {
                  if (value == 'logout') ref.read(authControllerProvider.notifier).logout();
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(user.email, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(children: [const Icon(Icons.logout, size: 18), const SizedBox(width: 8), Text(l10n.signOut)]),
                  ),
                ],
                child: CircleAvatar(radius: 18, backgroundColor: scheme.primary, child: Text(user.initials, style: const TextStyle(color: Colors.white, fontSize: 13))),
              ),
          ],
        ),
      ),
    );
  }
}
