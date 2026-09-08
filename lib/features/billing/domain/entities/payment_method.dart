/// A saved card — mock storage only (see [PaymentMethodsController]), never
/// sent anywhere real. Plain class (not freezed) since this is lightweight
/// UI-only mock state, not a domain entity backed by a repository.
class PaymentMethod {
  const PaymentMethod({required this.id, required this.brand, required this.last4, required this.holderName, this.isDefault = false});

  final String id;
  final String brand;
  final String last4;
  final String holderName;
  final bool isDefault;

  PaymentMethod copyWith({bool? isDefault}) {
    return PaymentMethod(id: id, brand: brand, last4: last4, holderName: holderName, isDefault: isDefault ?? this.isDefault);
  }
}
