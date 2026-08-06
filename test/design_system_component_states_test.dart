import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tevio_app/shared/design_system/tevio_design_system.dart';

void main() {
  testWidgets('search clear reports the cleared value', (tester) async {
    final controller = TextEditingController(text: 'VC-2401');
    var query = 'VC-2401';
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TevioSearchField(
            controller: controller,
            onChanged: (value) => query = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('검색어 지우기'));
    await tester.pump();

    expect(controller.text, isEmpty);
    expect(query, isEmpty);
  });

  testWidgets('control matrix supports disabled and descriptive states', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                TevioSelectField<String>(
                  label: '카테고리',
                  value: '생활가전',
                  items: const ['생활가전'],
                  labelBuilder: (item) => item,
                  onChanged: null,
                ),
                const TevioCheckControl(
                  value: true,
                  label: '알림 동의',
                  onChanged: null,
                ),
                const TevioRadioControl<String>(
                  value: '중요한 순',
                  groupValue: '중요한 순',
                  label: '중요한 순',
                  description: '안전과 기한이 임박한 항목을 먼저 봐요.',
                  onChanged: null,
                ),
                const TevioProgress(
                  value: .6,
                  label: '영수증 정보 확인',
                  showValue: true,
                ),
                const TevioSkeleton(height: 40, animate: false),
                TevioListItem(
                  title: '제품 상세',
                  subtitle: '등록한 정보와 권리 상태를 확인해요.',
                  onTap: _noop,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('카테고리'), findsOneWidget);
    expect(find.text('알림 동의'), findsOneWidget);
    expect(find.text('영수증 정보 확인'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('integration adapters expose retry and loading states', (
    tester,
  ) async {
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TevioDateField(
                label: '구매일',
                value: DateTime(2026, 8, 6),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                enabled: false,
                onChanged: _ignoreDate,
              ),
              TevioDocumentPreview(
                title: '영수증',
                description: 'PDF · 1.2 MB',
                errorText: '문서를 불러오지 못했어요.',
                onOpen: _noop,
                onRetry: () => retried = true,
              ),
              TevioPermissionRequest(
                icon: Icons.camera_alt_outlined,
                title: '카메라 접근',
                description: '영수증을 촬영할 때만 사용합니다.',
                isLoading: true,
                onRequest: _noop,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('문서 열기'));
    await tester.pump();

    expect(retried, isTrue);
    expect(find.text('문서를 불러오지 못했어요.'), findsOneWidget);
    expect(find.text('처리 중'), findsOneWidget);
  });
}

void _noop() {}

void _ignoreDate(DateTime? value) {}
