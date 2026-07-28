import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/infrastructure/result/tevio_failure.dart';
import '../../../../shared/infrastructure/result/tevio_result.dart';
import '../../data/product_repository.dart';
import '../../domain/models/product_summary.dart';

final productUpdateCommandProvider = Provider<ProductUpdateCommand>((ref) {
  return ProductUpdateCommand(ref);
});

class ProductUpdateCommand {
  const ProductUpdateCommand(this._ref);

  final Ref _ref;

  TevioResult<ProductSummary> save(ProductSummary product) {
    try {
      final savedProduct = _ref
          .read(productCatalogProvider.notifier)
          .updateProduct(product);

      return TevioSuccess(savedProduct);
    } on Exception {
      return const TevioFailureResult(
        TevioFailure(message: '제품 정보를 저장하지 못했어요. 잠시 후 다시 시도해 주세요.'),
      );
    }
  }
}
