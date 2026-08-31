import 'dart:io';

enum RegistrationAnalysisFailure { unreadableImage, network }

sealed class RegistrationAnalysisResult {
  const RegistrationAnalysisResult();
}

class RegistrationAnalysisSuccess extends RegistrationAnalysisResult {
  const RegistrationAnalysisSuccess(this.candidate);

  final RegistrationProductCandidate candidate;
}

class RegistrationAnalysisFailed extends RegistrationAnalysisResult {
  const RegistrationAnalysisFailed(this.failure);

  final RegistrationAnalysisFailure failure;
}

enum ModelLookupFailure { notFound, network }

sealed class ModelLookupResult {
  const ModelLookupResult();
}

class ModelLookupSuccess extends ModelLookupResult {
  const ModelLookupSuccess(this.candidate);

  final RegistrationProductCandidate candidate;
}

class ModelLookupFailed extends ModelLookupResult {
  const ModelLookupFailed(this.failure);

  final ModelLookupFailure failure;
}

class RegistrationProductCandidate {
  const RegistrationProductCandidate({
    required this.name,
    required this.brand,
    required this.modelNumber,
    required this.purchasedAt,
    required this.purchaseStore,
  });

  final String name;
  final String brand;
  final String modelNumber;
  final String purchasedAt;
  final String purchaseStore;
}

abstract interface class ProductRegistrationAnalysisRepository {
  Future<RegistrationAnalysisResult> analyzeReceipt(String imagePath);

  Future<ModelLookupResult> findByModelNumber(String modelNumber);
}

class MockProductRegistrationAnalysisRepository
    implements ProductRegistrationAnalysisRepository {
  const MockProductRegistrationAnalysisRepository();

  @override
  Future<RegistrationAnalysisResult> analyzeReceipt(String imagePath) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final file = File(imagePath);
    if (!await file.exists() || await file.length() == 0) {
      return const RegistrationAnalysisFailed(
        RegistrationAnalysisFailure.unreadableImage,
      );
    }
    return const RegistrationAnalysisSuccess(
      RegistrationProductCandidate(
        name: '공기청정기',
        brand: 'ABC',
        modelNumber: 'ABC-123',
        purchasedAt: '2026.07.23',
        purchaseStore: '브랜드 공식몰',
      ),
    );
  }

  @override
  Future<ModelLookupResult> findByModelNumber(String modelNumber) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final normalized = modelNumber.trim().toUpperCase();
    if (normalized == 'OFFLINE') {
      return const ModelLookupFailed(ModelLookupFailure.network);
    }
    if (normalized == 'UNKNOWN') {
      return const ModelLookupFailed(ModelLookupFailure.notFound);
    }
    return ModelLookupSuccess(
      RegistrationProductCandidate(
        name: '공기청정기',
        brand: 'ABC',
        modelNumber: normalized,
        purchasedAt: '',
        purchaseStore: '',
      ),
    );
  }
}
