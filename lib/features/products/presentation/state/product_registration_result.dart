import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/design_system/tevio_design_system.dart';
import '../../data/product_repository.dart';
import '../../domain/models/product_activity.dart';
import '../../domain/models/product_summary.dart';
import 'product_activity_queries.dart';

final productRegistrationResultProvider = Provider<ProductRegistrationResult>((
  ref,
) {
  return ProductRegistrationResult(ref);
});

class ProductRegistrationResult {
  const ProductRegistrationResult(this._ref);

  final Ref _ref;

  ProductSummary saveMockRegisteredProduct() {
    final product = ProductSummary(
      id: 'air-purifier-abc-123-registered',
      name: '공기청정기',
      brand: 'ABC',
      modelNumber: 'ABC-123',
      purchasedAt: '2026.07.23',
      purchaseStore: '브랜드 공식몰',
      warrantyText: '365일 남음',
      returnText: '14일 남음',
      receiptStatus: '보관됨',
      status: RightsStatus.detected,
      statusSummary: '등록이 완료되어 리콜과 보증 정보를 확인하고 있어요.',
      recommendedAction: '권리 상태 확인',
    );

    final savedProduct = _ref
        .read(productCatalogProvider.notifier)
        .addProduct(product);

    _ref
        .read(productActivityCommandProvider)
        .record(
          ProductActivity(
            id: '${savedProduct.id}-registered',
            productId: savedProduct.id,
            occurredAtLabel: '방금',
            title: '제품이 등록됐어요',
            description: '테비오가 리콜, 보증, 반품·교환 가능 기간을 확인하기 시작했어요.',
          ),
        );

    return savedProduct;
  }
}
