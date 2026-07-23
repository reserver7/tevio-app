import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tevio_app/app/theme/app_theme.dart';
import 'package:tevio_app/shared/design_system/tevio_design_system.dart';

void main() {
  testWidgets('TevioLogo renders text variant', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: TevioLogo()),
      ),
    );

    expect(find.text('테비오'), findsOneWidget);
  });

  testWidgets('TevioRightsCard shows status and action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: TevioRightsCard(
            status: RightsStatus.urgent,
            productName: '무선청소기',
            title: '리콜 가능성이 감지됐어요',
            description: '공식 리콜 정보와 유사한 항목이 있어요.',
            actionLabel: '리콜 내용 확인',
          ),
        ),
      ),
    );

    expect(find.text('긴급'), findsOneWidget);
    expect(find.text('리콜 내용 확인'), findsOneWidget);
  });
}
