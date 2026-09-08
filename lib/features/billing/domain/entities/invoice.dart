enum InvoiceStatus { paid, pending }

/// A billing-history row (subscription charges, consultation payments) —
/// mock storage only (see [InvoicesController]).
class Invoice {
  const Invoice({required this.id, required this.title, required this.amount, required this.date, required this.status});

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final InvoiceStatus status;
}
