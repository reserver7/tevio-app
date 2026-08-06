import '../../../../shared/design_system/tevio_design_system.dart';

class ProductStatusResolver {
  const ProductStatusResolver();

  ProductStatusResult resolve({
    required String modelNumber,
    required String receiptStatus,
  }) {
    final model = modelNumber.trim().toUpperCase();
    final status = _statusFor(model, receiptStatus);
    final isConnectionFailure =
        model.contains('OFFLINE') || model.contains('FAIL');

    return ProductStatusResult(
      status: status,
      summary: switch (status) {
        RightsStatus.urgent => '공식 리콜 정보와 유사한 모델이 있어 사용을 멈추고 확인해 주세요.',
        RightsStatus.actionRequired => '무상보증 종료 전에 필요한 정보를 확인해 주세요.',
        RightsStatus.unknown =>
          isConnectionFailure
              ? '연결 문제로 권리 상태를 확인하지 못했어요. 잠시 후 다시 시도해 주세요.'
              : '일부 정보가 부족해 권리 상태를 정확히 확인하지 못했어요.',
        RightsStatus.safe => '현재 등록된 정보 기준으로 확인할 문제는 없어요.',
        RightsStatus.detected => '등록된 제품 정보를 확인하고 있어요.',
        RightsStatus.processing => '제품 권리 상태를 확인하고 있어요.',
        RightsStatus.completed => '제품 권리 상태 확인을 완료했어요.',
      },
      actionLabel: status == RightsStatus.urgent
          ? '리콜 내용 확인'
          : status == RightsStatus.actionRequired
          ? '보증 정보 확인'
          : status == RightsStatus.unknown
          ? isConnectionFailure
                ? '다시 확인하기'
                : '정보 보완하기'
          : '상태 상세 보기',
    );
  }

  RightsStatus _statusFor(String model, String receiptStatus) {
    if (model.contains('RECALL') || model.contains('URGENT')) {
      return RightsStatus.urgent;
    }
    if (model.contains('WARRANTY') || model.contains('DUE')) {
      return RightsStatus.actionRequired;
    }
    if (model.contains('UNKNOWN') ||
        model.contains('OFFLINE') ||
        model.contains('FAIL') ||
        receiptStatus == '확인 필요') {
      return RightsStatus.unknown;
    }
    return RightsStatus.safe;
  }
}

class ProductStatusResult {
  const ProductStatusResult({
    required this.status,
    required this.summary,
    required this.actionLabel,
  });

  final RightsStatus status;
  final String summary;
  final String actionLabel;
}
