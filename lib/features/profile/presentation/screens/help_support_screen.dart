import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_bottom_sheet.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/core/widgets/section_header.dart';

class _Faq {
  const _Faq(this.question, this.answer);
  final String question;
  final String answer;
}

/// Account → Help & Support — static FAQ list + a mock "contact support"
/// form (no real ticketing backend, just a success confirmation).
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  List<_Faq> _faqs(AppLocalizations l10n) => [
    _Faq(l10n.helpFaqNewContractQuestion, l10n.helpFaqNewContractAnswer),
    _Faq(l10n.helpFaqEsignatureQuestion, l10n.helpFaqEsignatureAnswer),
    _Faq(l10n.helpFaqBookConsultationQuestion, l10n.helpFaqBookConsultationAnswer),
    _Faq(l10n.helpFaqManageSubscriptionQuestion, l10n.helpFaqManageSubscriptionAnswer),
  ];

  Future<void> _contactSupport(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

    final sent = await showAppBottomSheet<bool>(
      context,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.helpContactUs, style: Theme.of(sheetContext).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            AppTextField(controller: subjectController, label: l10n.helpSubjectLabel),
            const SizedBox(height: AppSpacing.md),
            AppTextField(controller: messageController, label: l10n.helpMessageLabel, maxLines: 4),
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: l10n.helpSendMessage, onPressed: () => Navigator.of(sheetContext).pop(true)),
          ],
        );
      },
    );
    if (sent == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.helpRequestSentMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final faqs = _faqs(l10n);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpSupportTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            SectionHeader(title: l10n.helpFaqTitle),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < faqs.length; i++) ...[
                    ExpansionTile(title: Text(faqs[i].question), children: [Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md), child: Align(alignment: AlignmentDirectional.centerStart, child: Text(faqs[i].answer)))]),
                    if (i != faqs.length - 1) const Divider(height: 1),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: l10n.helpContactUs, icon: Icons.support_agent_outlined, onPressed: () => _contactSupport(context)),
          ],
        ),
      ),
    );
  }
}
