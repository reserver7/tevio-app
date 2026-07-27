import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/product_repository.dart';
import '../../domain/models/product_summary.dart';

final productUpdateCommandProvider = Provider<ProductUpdateCommand>((ref) {
  return ProductUpdateCommand(ref);
});

class ProductUpdateCommand {
  const ProductUpdateCommand(this._ref);

  final Ref _ref;

  ProductSummary save(ProductSummary product) {
    return _ref.read(productCatalogProvider.notifier).updateProduct(product);
  }
}
