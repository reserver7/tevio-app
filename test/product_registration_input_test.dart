import 'package:flutter_test/flutter_test.dart';
import 'package:tevio_app/features/products/presentation/state/product_registration_result.dart';

void main() {
  test('ProductRegistrationInput requires core product fields', () {
    const input = ProductRegistrationInput(
      name: '공기청정기',
      brand: 'ABC',
      modelNumber: 'ABC-123',
      purchasedAt: '',
      purchaseStore: '',
    );

    expect(input.isValid, isTrue);
  });

  test('ProductRegistrationInput normalizes optional fields', () {
    const input = ProductRegistrationInput(
      name: ' 공기청정기 ',
      brand: ' ABC ',
      modelNumber: ' ABC-123 ',
      purchasedAt: '',
      purchaseStore: '',
    );

    final normalizedInput = input.normalized();

    expect(normalizedInput.name, '공기청정기');
    expect(normalizedInput.brand, 'ABC');
    expect(normalizedInput.modelNumber, 'ABC-123');
    expect(normalizedInput.purchasedAt, '구매일 미상');
    expect(normalizedInput.purchaseStore, '구매처 미상');
  });

  test('ProductRegistrationInput summarizes enabled alerts', () {
    const input = ProductRegistrationInput(
      name: '공기청정기',
      brand: 'ABC',
      modelNumber: 'ABC-123',
      purchasedAt: '2026.07.28',
      purchaseStore: '공식몰',
      recallAlert: true,
      warrantyAlert: false,
      returnAlert: true,
    );

    expect(input.alertSummary, '리콜, 반품·교환 알림을 설정했어요.');
  });

  test('ProductRegistrationInput summarizes disabled alerts', () {
    const input = ProductRegistrationInput(
      name: '공기청정기',
      brand: 'ABC',
      modelNumber: 'ABC-123',
      purchasedAt: '2026.07.28',
      purchaseStore: '공식몰',
      recallAlert: false,
      warrantyAlert: false,
      returnAlert: false,
    );

    expect(input.alertSummary, '등록한 알림은 없어요.');
  });
}
