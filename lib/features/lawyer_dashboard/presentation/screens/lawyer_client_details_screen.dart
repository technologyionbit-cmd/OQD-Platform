import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/core/widgets/section_header.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/consultations_controller.dart';
import 'package:aqd_ionbit/features/consultations/presentation/widgets/consultation_card.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';

class LawyerClientDetailsScreen extends ConsumerWidget {
  const LawyerClientDetailsScreen({super.key, required this.clientName});

  final String clientName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final consultationsState = ref.watch(consultationsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(clientName)),
      body: switch (consultationsState) {
        AsyncData(value: final consultations) => Builder(
          builder: (context) {
            final history = consultations.where((c) => c.lawyerId == kDemoLawyerId && c.clientName == clientName).toList()
              ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  Row(
                    children: [
                      const IconBadge(icon: Icons.person_outline, size: 56),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(clientName, style: Theme.of(context).textTheme.titleLarge),
                            Text(l10n.clientsConsultationCount(history.length), style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SectionHeader(title: l10n.navConsultations),
                  const SizedBox(height: AppSpacing.sm),
                  if (history.isEmpty)
                    EmptyState(icon: Icons.event_note_outlined, message: l10n.consultationsEmptyMessage)
                  else
                    Column(
                      children: [
                        for (final c in history) ...[
                          ConsultationCard(
                            consultation: c,
                            showLawyerName: false,
                            onTap: () => context.push(RoutePaths.lawyerConsultationDetails(c.id)),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      ],
                    ),
                ],
              ),
            );
          },
        ),
        AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.read(consultationsControllerProvider.notifier).refresh()),
        _ => const LoadingView(),
      },
    );
  }
}
