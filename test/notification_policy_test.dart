import 'package:flutter_test/flutter_test.dart';

import 'package:tevio_app/features/notifications/domain/models/tevio_notification.dart';
import 'package:tevio_app/features/products/domain/models/product_summary.dart';
import 'package:tevio_app/features/settings/presentation/state/notification_settings.dart';
import 'package:tevio_app/shared/design_system/tevio_design_system.dart';

void main() {
  const product = ProductSummary(
    id: 'product',
    name: '노트북',
    brand: 'ABC',
    modelNumber: 'ABC-1',
    purchasedAt: '2026.01.01',
    purchaseStore: '공식몰',
    warrantyText: '30일 남음',
    returnText: '종료',
    receiptStatus: '보관됨',
    status: RightsStatus.safe,
    statusSummary: '정상',
    recommendedAction: '상세보기',
    warrantyAlertEnabled: false,
  );

  test('device permission blocks every new notification', () {
    expect(
      NotificationPolicy.allows(
        category: TevioNotificationCategory.immediate,
        globalSettings: const NotificationSettings(),
        product: product,
        devicePermissionGranted: false,
      ),
      isFalse,
    );
  });

  test('product setting overrides the global setting for its category', () {
    expect(
      NotificationPolicy.allows(
        category: TevioNotificationCategory.dueSoon,
        globalSettings: const NotificationSettings(),
        product: product,
      ),
      isFalse,
    );
  });

  test('processing uses the global setting', () {
    expect(
      NotificationPolicy.allows(
        category: TevioNotificationCategory.processing,
        globalSettings: const NotificationSettings(processing: false),
        product: product,
      ),
      isFalse,
    );
  });
}
