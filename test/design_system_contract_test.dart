import 'package:flutter_test/flutter_test.dart';
import 'package:tevio_app/shared/design_system/tevio_design_system.dart';

void main() {
  test('Tevio interaction dimensions follow the product contract', () {
    expect(TevioDimensions.minTouchTarget, greaterThanOrEqualTo(44));
    expect(TevioDimensions.buttonHeight, greaterThanOrEqualTo(48));
    expect(TevioDimensions.inputHeight, greaterThanOrEqualTo(48));
  });

  test('Tevio status colors expose semantic states', () {
    expect(TevioSemanticColors.actionPrimary, TevioColors.primary);
    expect(TevioSemanticColors.feedbackDanger, TevioColors.danger);
    expect(TevioSemanticColors.feedbackSuccess, TevioColors.mint);
  });
}
