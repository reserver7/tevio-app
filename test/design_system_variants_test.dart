import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tevio_app/shared/design_system/tevio_design_system.dart';

void main() {
  testWidgets('core components expose stable variants and semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(useMaterial3: true),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                TevioButton(label: 'Primary', onPressed: _noop),
                TevioButton(
                  label: 'Secondary',
                  variant: TevioButtonVariant.secondary,
                  onPressed: _noop,
                ),
                TevioButton(
                  label: 'Danger',
                  variant: TevioButtonVariant.danger,
                  onPressed: _noop,
                ),
                TevioButton(
                  label: 'Compact',
                  size: TevioButtonSize.compact,
                  isExpanded: false,
                  onPressed: _noop,
                ),
                TevioStatusBadge(status: RightsStatus.urgent),
                TevioStatusBadge(status: RightsStatus.processing),
                TevioStatusBadge(status: RightsStatus.safe),
                TevioFeedbackBanner(
                  status: RightsStatus.actionRequired,
                  title: '확인이 필요해요',
                  description: '제품 정보를 확인해 주세요.',
                ),
                TevioDateField(
                  label: '구매일',
                  value: DateTime(2026, 8, 6),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  onChanged: _ignoreDate,
                ),
                TevioDocumentPreview(
                  title: '영수증',
                  description: 'PDF · 1.2 MB',
                  onOpen: _noop,
                ),
                const TevioNetworkImage(
                  imageUrl: null,
                  semanticLabel: '제품 이미지 자리표시자',
                  width: 72,
                  height: 72,
                ),
                TevioPermissionRequest(
                  icon: Icons.camera_alt_outlined,
                  title: '카메라 접근',
                  description: '영수증을 촬영할 때만 카메라를 사용합니다.',
                  actionLabel: '직접 입력으로 계속',
                  onRequest: _noop,
                ),
                TevioActionCard(
                  status: RightsStatus.actionRequired,
                  eyebrow: 'XYZ 무선청소기',
                  title: '모델번호를 확인해 주세요',
                  description: '리콜 대상 여부를 정확하게 확인할 수 있어요.',
                  actionLabel: '제품 정보 보기',
                  onPressed: _noop,
                ),
                TevioListRow(
                  icon: Icons.notifications_outlined,
                  title: '알림 설정',
                  description: '리콜과 보증 만료를 알려드려요.',
                  onTap: _noop,
                ),
                const TevioListRow(
                  icon: Icons.info_outline,
                  title: '앱 정보',
                  value: '1.0.0',
                ),
                TevioSelectionTile(
                  icon: Icons.document_scanner_outlined,
                  title: '영수증으로 등록',
                  description: '사진에서 구매 정보를 읽어옵니다.',
                  selected: true,
                  onTap: _noop,
                ),
                const TevioSwitch(
                  value: false,
                  label: '리콜 알림',
                  description: '안전 문제와 공식 조치가 감지되면 알려드려요.',
                  onChanged: null,
                ),
                TevioSegmentedControl<String>(
                  items: const ['전체', '읽지 않음'],
                  selected: '전체',
                  labelBuilder: (item) => item,
                  onChanged: _ignoreString,
                ),
                TevioTabs<String>(
                  items: const ['전체', '제품'],
                  selected: '전체',
                  labelBuilder: (item) => item,
                  onChanged: _ignoreString,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('긴급'), findsOneWidget);
    expect(find.text('처리 중'), findsOneWidget);
    expect(find.text('정상'), findsOneWidget);
    expect(find.text('2026. 08. 06.'), findsOneWidget);
    expect(find.text('영수증'), findsOneWidget);
    expect(find.text('카메라 접근'), findsOneWidget);
    expect(find.text('모델번호를 확인해 주세요'), findsOneWidget);
    expect(find.text('제품 정보 보기'), findsOneWidget);
    expect(find.text('알림 설정'), findsOneWidget);
    expect(find.text('영수증으로 등록'), findsOneWidget);
    expect(find.text('리콜 알림'), findsOneWidget);
    expect(find.text('Compact'), findsOneWidget);
    expect(find.bySemanticsLabel('제품 이미지 자리표시자'), findsOneWidget);
  });

  testWidgets('confirm sheet returns an explicit user decision', (
    tester,
  ) async {
    bool? decision;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TevioButton(
              label: '삭제 확인',
              onPressed: () async {
                decision = await TevioSheet.show<bool>(
                  context,
                  builder: (context) => const TevioConfirmSheet(
                    title: '제품을 삭제할까요?',
                    description: '삭제한 제품은 목록에서 제외됩니다.',
                    confirmLabel: '제품 삭제',
                    isDestructive: true,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('삭제 확인'));
    await tester.pumpAndSettle();

    expect(find.text('제품을 삭제할까요?'), findsOneWidget);
    expect(find.text('취소'), findsOneWidget);

    await tester.tap(find.text('제품 삭제'));
    await tester.pumpAndSettle();

    expect(decision, isTrue);
  });
}

void _noop() {}

void _ignoreDate(DateTime? value) {}

void _ignoreString(String value) {}
