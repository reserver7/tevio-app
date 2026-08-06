import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/product_summary.dart';
import 'dtos/product_dto.dart';
import 'mappers/product_mapper.dart';
import 'mock_products.dart';

abstract interface class ProductRepository {
  List<ProductSummary> watchProducts();

  ProductSummary? findProductById(String? id);

  ProductSummary addProduct(ProductSummary product);

  ProductSummary updateProduct(ProductSummary product);

  ProductSummary? removeProduct(String id);

  void restoreProduct(ProductSummary product);
}

final productCatalogProvider =
    NotifierProvider<ProductCatalog, List<ProductSummary>>(ProductCatalog.new);

class ProductCatalog extends Notifier<List<ProductSummary>>
    implements ProductRepository {
  static const _productsStorageKey = 'products.catalog';

  @override
  List<ProductSummary> build() {
    final products = [for (final dto in mockProductDtos) dto.toDomain()];
    unawaited(_restoreProducts(products));
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
      unawaited(_persistProducts());
      unawaited(_persistAlertSettings(product));
      return product;
    }

    state = [product, ...state];
    unawaited(_persistProducts());
    unawaited(_persistAlertSettings(product));
    return product;
  }

  @override
  ProductSummary updateProduct(ProductSummary product) {
    state = [for (final item in state) item.id == product.id ? product : item];
    unawaited(_persistProducts());
    unawaited(_persistAlertSettings(product));

    return product;
  }

  @override
  ProductSummary? removeProduct(String id) {
    final product = findProductById(id);
    if (product == null) {
      return null;
    }

    state = [
      for (final item in state)
        if (item.id != id) item,
    ];
    unawaited(_persistProducts());
    return product;
  }

  @override
  void restoreProduct(ProductSummary product) {
    if (state.any((item) => item.id == product.id)) {
      return;
    }

    state = [product, ...state];
    unawaited(_persistProducts());
    unawaited(_persistAlertSettings(product));
  }

  Future<void> _restoreProducts(List<ProductSummary> fallback) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_productsStorageKey);
    if (encoded == null || !ref.mounted) {
      return;
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) {
        return;
      }

      state = [
        for (final item in decoded)
          if (item is Map<String, dynamic>) _productFromMap(item),
      ];
    } on FormatException {
      // Keep the bundled mock catalog when local data is invalid.
    }
  }

  Future<void> _persistProducts() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode([
      for (final product in state) _productToMap(product),
    ]);
    await preferences.setString(_productsStorageKey, encoded);
  }

  ProductSummary _productFromMap(Map<String, dynamic> map) {
    return ProductDto(
      id: map['id'] as String,
      name: map['name'] as String,
      brand: map['brand'] as String,
      modelNumber: map['modelNumber'] as String,
      purchasedAt: map['purchasedAt'] as String,
      purchaseStore: map['purchaseStore'] as String,
      warrantyText: map['warrantyText'] as String,
      returnText: map['returnText'] as String,
      receiptStatus: map['receiptStatus'] as String,
      status: map['status'] as String,
      statusSummary: map['statusSummary'] as String,
      recommendedAction: map['recommendedAction'] as String,
      recallAlertEnabled: map['recallAlertEnabled'] as bool? ?? true,
      warrantyAlertEnabled: map['warrantyAlertEnabled'] as bool? ?? true,
      returnAlertEnabled: map['returnAlertEnabled'] as bool? ?? true,
      lastCheckedAt: DateTime.tryParse(map['lastCheckedAt'] as String? ?? ''),
    ).toDomain();
  }

  Map<String, dynamic> _productToMap(ProductSummary product) {
    final dto = product.toDto();
    return {
      'id': dto.id,
      'name': dto.name,
      'brand': dto.brand,
      'modelNumber': dto.modelNumber,
      'purchasedAt': dto.purchasedAt,
      'purchaseStore': dto.purchaseStore,
      'warrantyText': dto.warrantyText,
      'returnText': dto.returnText,
      'receiptStatus': dto.receiptStatus,
      'status': dto.status,
      'statusSummary': dto.statusSummary,
      'recommendedAction': dto.recommendedAction,
      'recallAlertEnabled': dto.recallAlertEnabled,
      'warrantyAlertEnabled': dto.warrantyAlertEnabled,
      'returnAlertEnabled': dto.returnAlertEnabled,
      'lastCheckedAt': dto.lastCheckedAt?.toIso8601String(),
    };
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
