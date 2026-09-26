import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/billing/domain/entities/payment_method.dart';

/// Saved cards for the Account → Payment Methods screen — mock storage
/// only, seeded with one demo card so the screen isn't empty by default.
class PaymentMethodsController extends Notifier<List<PaymentMethod>> {
  @override
  List<PaymentMethod> build() => const [
    PaymentMethod(id: 'pm_demo', brand: 'visa', last4: '4242', holderName: 'محمد الأحمدي', isDefault: true),
  ];

  Future<void> addCard({required String brand, required String last4, required String holderName}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final card = PaymentMethod(
      id: 'pm_${DateTime.now().microsecondsSinceEpoch}',
      brand: brand,
      last4: last4,
      holderName: holderName,
      isDefault: state.isEmpty,
    );
    state = [...state, card];
  }

  void setDefault(String id) {
    state = [for (final card in state) card.copyWith(isDefault: card.id == id)];
  }

  void remove(String id) {
    state = state.where((card) => card.id != id).toList();
  }
}

final paymentMethodsControllerProvider = NotifierProvider<PaymentMethodsController, List<PaymentMethod>>(PaymentMethodsController.new);
