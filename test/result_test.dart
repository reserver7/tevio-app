import 'package:flutter_test/flutter_test.dart';
import 'package:tevio_app/shared/infrastructure/result/tevio_failure.dart';
import 'package:tevio_app/shared/infrastructure/result/tevio_result.dart';

void main() {
  test('TevioResult returns success value', () {
    const result = TevioSuccess('saved');

    final value = result.when(
      success: (value) => value,
      failure: (failure) => failure.message,
    );

    expect(value, 'saved');
  });

  test('TevioResult returns failure message', () {
    const result = TevioFailureResult<String>(
      TevioFailure(message: '저장하지 못했어요.'),
    );

    final value = result.when(
      success: (value) => value,
      failure: (failure) => failure.message,
    );

    expect(value, '저장하지 못했어요.');
  });
}
