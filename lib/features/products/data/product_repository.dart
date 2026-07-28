import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/product_summary.dart';
import 'mappers/product_mapper.dart';
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
    final products = [for (final dto in mockProductDtos) dto.toDomain()];
    unawaited(_restoreAlertSettings(products));
    return products;
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
      unawaited(_persistAlertSettings(product));
      return product;
    }

    state = [product, ...state];
    unawaited(_persistAlertSettings(product));
    return product;
  }

  @override
  ProductSummary updateProduct(ProductSummary product) {
    state = [for (final item in state) item.id == product.id ? product : item];
    unawaited(_persistAlertSettings(product));

    return product;
  }

  Future<void> _restoreAlertSettings(List<ProductSummary> products) async {
    final preferences = await SharedPreferences.getInstance();
    if (!ref.mounted) {
      return;
    }

    state = [
      for (final product in state)
        product.copyWith(
          recallAlertEnabled: preferences.getBool(
            _alertKey(product.id, 'recall'),
          ),
          warrantyAlertEnabled: preferences.getBool(
            _alertKey(product.id, 'warranty'),
          ),
          returnAlertEnabled: preferences.getBool(
            _alertKey(product.id, 'return'),
          ),
        ),
    ];
  }

  Future<void> _persistAlertSettings(ProductSummary product) async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setBool(
        _alertKey(product.id, 'recall'),
        product.recallAlertEnabled,
      ),
      preferences.setBool(
        _alertKey(product.id, 'warranty'),
        product.warrantyAlertEnabled,
      ),
      preferences.setBool(
        _alertKey(product.id, 'return'),
        product.returnAlertEnabled,
      ),
    ]);
  }

  String _alertKey(String productId, String type) {
    return 'product_alerts.$productId.$type';
  }
}
