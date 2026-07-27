import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final libFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  test('features and app use the design system barrel only', () {
    final violations = <String>[];

    for (final file in libFiles.where(_isAppOrFeatureFile)) {
      final source = file.readAsStringSync();

      if (source.contains('shared/design_system/tokens/') ||
          source.contains('shared/design_system/components/') ||
          source.contains('shared/design_system/models/')) {
        violations.add(file.path);
      }
    }

    expect(
      violations,
      isEmpty,
      reason: '앱과 feature 코드는 tevio_design_system.dart 배럴만 import해야 합니다.',
    );
  });

  test('pages do not import feature data sources directly', () {
    final violations = <String>[];

    for (final file in libFiles.where(_isPresentationPageFile)) {
      final source = file.readAsStringSync();

      if (source.contains('/data/') ||
          source.contains("import '../../data/") ||
          source.contains("import '../data/")) {
        violations.add(file.path);
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'page는 state/query provider를 통해 data 계층을 사용해야 합니다.',
    );
  });

  test('mock data stays behind repositories', () {
    final violations = <String>[];

    for (final file in libFiles) {
      if (file.path.contains('/data/')) {
        continue;
      }

      final source = file.readAsStringSync();

      if (source.contains('mockProducts') ||
          source.contains('mockNotifications')) {
        violations.add(file.path);
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'mock 데이터는 repository 구현 내부에서만 직접 참조해야 합니다.',
    );
  });

  test('raw design values stay inside design system token files', () {
    final violations = <String>[];

    for (final file in libFiles) {
      if (_isTokenFile(file)) {
        continue;
      }

      final source = file.readAsStringSync();
      final hasRawColor = source.contains(RegExp(r'\bColor\(0x'));
      final hasMaterialColors = source.contains(
        RegExp(r'(^|[^A-Za-z0-9_])Colors\.'),
      );
      final hasRawTextStyle = source.contains(RegExp(r'\bTextStyle\('));
      final hasRawRadius =
          source.contains(RegExp(r'\bRadius\.circular\(')) ||
          source.contains(RegExp(r'\bBorderRadius\.'));

      if (hasRawColor || hasMaterialColors || hasRawTextStyle || hasRawRadius) {
        violations.add(file.path);
      }
    }

    expect(
      violations,
      isEmpty,
      reason: '색상, 타이포그래피, radius 원시값은 design system token으로 승격해야 합니다.',
    );
  });

  test('product wording follows Tevio brand language', () {
    final bannedPatterns = {
      '산 이후': '구매 이후',
      '컨슈머': '테비오 사용자',
      '소비자 권리관리': '구매 이후 권리 관리',
    };
    final violations = <String>[];

    for (final file in libFiles) {
      final source = file.readAsStringSync();

      for (final entry in bannedPatterns.entries) {
        if (source.contains(entry.key)) {
          violations.add('${file.path}: `${entry.key}` 대신 `${entry.value}` 사용');
        }
      }
    }

    expect(violations, isEmpty, reason: '앱 문구는 테비오 브랜드 언어 규격을 따라야 합니다.');
  });
}

bool _isPresentationPageFile(File file) {
  return file.path.contains('/presentation/pages/');
}

bool _isAppOrFeatureFile(File file) {
  return file.path.startsWith('lib/app/') ||
      file.path.startsWith('lib/features/');
}

bool _isTokenFile(File file) {
  return file.path.startsWith('lib/shared/design_system/tokens/');
}
