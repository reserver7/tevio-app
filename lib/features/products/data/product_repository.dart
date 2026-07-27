import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/product_summary.dart';
import 'mock_products.dart';

abstract interface class ProductRepository {
  List<ProductSummary> watchProducts();

  ProductSummary? findProductById(String? id);

  ProductSummary addProduct(ProductSummary product);

  ProductSummary updateProduct(ProductSummary product);
}

final productCatalogProvider =
    NotifierProvider<ProductCatalog, List<ProductSummary>>(ProductCatalog.new);

class ProductCatalog extends Notifier<List<ProductSummary>>
    implements ProductRepository {
  @override
  List<ProductSummary> build() {
    return mockProducts;
  }

  @override
  List<ProductSummary> watchProducts() {
    return state;
  }

  @override
  ProductSummary? findProductById(String? id) {
    if (id == null) {
      return null;
    }

    for (final product in state) {
      if (product.id == id) {
        return product;
      }
    }

    return null;
  }

  @override
  ProductSummary addProduct(ProductSummary product) {
    final existingIndex = state.indexWhere((item) => item.id == product.id);

    if (existingIndex >= 0) {
      final nextProducts = [...state];
      nextProducts[existingIndex] = product;
      state = nextProducts;
      return product;
    }

    state = [product, ...state];
    return product;
  }

  @override
  ProductSummary updateProduct(ProductSummary product) {
    state = [for (final item in state) item.id == product.id ? product : item];

    return product;
  }
}
