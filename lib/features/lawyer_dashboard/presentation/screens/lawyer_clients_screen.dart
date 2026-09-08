import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/consultations_controller.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';

/// The demo lawyer's client roster — derived from her own consultation
/// history (every unique client she's had a booking with) rather than a
/// separate client-management mock backend, so it never drifts from the
/// consultations feature's data.
class LawyerClientsScreen extends ConsumerStatefulWidget {
  const LawyerClientsScreen({super.key});

  @override
  ConsumerState<LawyerClientsScreen> createState() => _LawyerClientsScreenState();
}

class _LawyerClientsScreenState extends ConsumerState<LawyerClientsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final consultationsState = ref.watch(consultationsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navClients)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.sm),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(hintText: l10n.clientsSearchHint, prefixIcon: const Icon(Icons.search)),
              ),
            ),
            Expanded(
              child: switch (consultationsState) {
                AsyncData(value: final consultations) => Builder(
                  builder: (context) {
                    final mine = consultations.where((c) => c.lawyerId == kDemoLawyerId);
                    final byClient = <String, int>{};
                    final lastSeen = <String, DateTime>{};
                    for (final c in mine) {
                      byClient[c.clientName] = (byClient[c.clientName] ?? 0) + 1;
                      final existing = lastSeen[c.clientName];
                      if (existing == null || c.scheduledAt.isAfter(existing)) lastSeen[c.clientName] = c.scheduledAt;
                    }
                    final names = byClient.keys.where((name) => name.toLowerCase().contains(_query.toLowerCase())).toList()
                      ..sort((a, b) => lastSeen[b]!.compareTo(lastSeen[a]!));

                    if (names.isEmpty) {
                      return EmptyState(icon: Icons.people_outline, title: l10n.clientsEmptyTitle, message: l10n.clientsEmptyMessage);
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
                      itemCount: names.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final name = names[index];
                        return AppCard(
                          onTap: () => context.push(RoutePaths.lawyerClientDetails(name)),
                          child: Row(
                            children: [
                              const IconBadge(icon: Icons.person_outline, size: 44),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: Theme.of(context).textTheme.titleSmall),
                                    Text(
                                      l10n.clientsConsultationCount(byClient[name]!),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.read(consultationsControllerProvider.notifier).refresh()),
                _ => const LoadingView(),
              },
            ),
          ],
        ),
      ),
    );
  }
}
