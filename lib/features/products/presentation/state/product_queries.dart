import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/product_repository.dart';
import '../../domain/models/product_summary.dart';

final productSummariesQueryProvider = Provider<List<ProductSummary>>((ref) {
  return ref.watch(productCatalogProvider);
});

final productSummaryQueryProvider = Provider.family<ProductSummary?, String?>((
  ref,
  id,
) {
  ref.watch(productCatalogProvider);
  return ref.read(productCatalogProvider.notifier).findProductById(id);
});
