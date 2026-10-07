import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/auth/presentation/providers/current_user_id_provider.dart';
import 'package:aqd_ionbit/features/billing/domain/entities/invoice.dart';

/// Billing history for the Account → Invoices screen — mock storage only,
/// seeded with a couple of demo rows. [add] is called by the subscription
/// and consultation-payment success flows so a real purchase actually shows
/// up here, instead of the list being permanently static.
class InvoicesController extends Notifier<List<Invoice>> {
  @override
  List<Invoice> build() {
    ref.watch(currentUserIdProvider); // Fresh state for each account.
    return [
      Invoice(id: 'inv_1', title: 'استشارة قانونية مع أ. سامر العمري', amount: 35, date: DateTime.now().subtract(const Duration(days: 15)), status: InvoiceStatus.paid),
      Invoice(id: 'inv_2', title: 'تحليل عقد بالذكاء الاصطناعي', amount: 15, date: DateTime.now().subtract(const Duration(days: 28)), status: InvoiceStatus.paid),
    ];
  }

  void add(Invoice invoice) => state = [invoice, ...state];
}

final invoicesControllerProvider = NotifierProvider<InvoicesController, List<Invoice>>(InvoicesController.new);
