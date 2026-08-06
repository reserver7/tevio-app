import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tevio_app/shared/design_system/catalog/tevio_catalog_page.dart';

void main() {
  testWidgets('catalog remains usable on a small screen with large text', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(320, 568)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: MaterialApp(home: TevioCatalogPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tevio UI Kit'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
