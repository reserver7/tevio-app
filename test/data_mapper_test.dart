import 'package:flutter_test/flutter_test.dart';
import 'package:tevio_app/features/notifications/data/dtos/notification_dto.dart';
import 'package:tevio_app/features/notifications/data/mappers/notification_mapper.dart';
import 'package:tevio_app/features/notifications/domain/models/tevio_notification.dart';
import 'package:tevio_app/features/products/data/dtos/product_activity_dto.dart';
import 'package:tevio_app/features/products/data/dtos/product_dto.dart';
import 'package:tevio_app/features/products/data/mappers/product_mapper.dart';
import 'package:tevio_app/shared/design_system/tevio_design_system.dart';

void main() {
  test('ProductDto maps to ProductSummary', () {
    const dto = ProductDto(
      id: 'product-1',
      name: '무선청소기',
      brand: 'XYZ',
      modelNumber: 'VC-2401',
      purchasedAt: '2026.07.28',
      purchaseStore: '공식몰',
      warrantyText: '30일 남음',
      returnText: '반품 기간 종료',
      receiptStatus: '보관됨',
      status: 'urgent',
      statusSummary: '리콜 확인이 필요해요.',
      recommendedAction: '리콜 내용 확인',
    );

    final product = dto.toDomain();

    expect(product.id, 'product-1');
    expect(product.status, RightsStatus.urgent);
    expect(product.recommendedAction, '리콜 내용 확인');
  });

  test('NotificationDto maps to TevioNotification', () {
    const dto = NotificationDto(
      id: 'notification-1',
      category: 'dueSoon',
      status: 'actionRequired',
      productName: '노트북',
      typeLabel: '기한 알림',
      title: '무상보증 종료 전',
      description: '영수증을 확인하세요.',
      receivedAt: '방금',
      groupLabel: '오늘',
      actionLabel: '보증 보기',
      route: '/products/notebook',
    );

    final notification = dto.toDomain();

    expect(notification.category, TevioNotificationCategory.dueSoon);
    expect(notification.status, RightsStatus.actionRequired);
    expect(notification.isRead, isFalse);
  });

  test('ProductActivityDto maps to ProductActivity', () {
    const dto = ProductActivityDto(
      id: 'activity-1',
      productId: 'product-1',
      occurredAtLabel: '방금',
      title: '제품 정보가 수정됐어요',
      description: '권리 상태를 다시 확인합니다.',
    );

    final activity = dto.toDomain();

    expect(activity.productId, 'product-1');
    expect(activity.title, '제품 정보가 수정됐어요');
  });
}
