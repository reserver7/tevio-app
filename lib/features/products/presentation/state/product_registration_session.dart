import 'package:flutter_riverpod/flutter_riverpod.dart';

final productRegistrationSessionProvider =
    NotifierProvider<ProductRegistrationSession, int>(
      ProductRegistrationSession.new,
    );

final productRegistrationDraftProvider =
    NotifierProvider<
      ProductRegistrationDraftController,
      ProductRegistrationDraft?
    >(ProductRegistrationDraftController.new);

class ProductRegistrationDraft {
  const ProductRegistrationDraft({
    required this.step,
    required this.method,
    required this.name,
    required this.brand,
    required this.modelNumber,
    required this.purchasedAt,
    required this.purchaseStore,
    required this.mediaPath,
    required this.recallAlert,
    required this.warrantyAlert,
    required this.returnAlert,
  });

  final int step;
  final int? method;
  final String name;
  final String brand;
  final String modelNumber;
  final String purchasedAt;
  final String purchaseStore;
  final String? mediaPath;
  final bool recallAlert;
  final bool warrantyAlert;
  final bool returnAlert;
}

class ProductRegistrationDraftController
    extends Notifier<ProductRegistrationDraft?> {
  @override
  ProductRegistrationDraft? build() => null;

  void save(ProductRegistrationDraft draft) => state = draft;

  void clear() => state = null;
}

class ProductRegistrationSession extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void reset() {
    state++;
  }
}
