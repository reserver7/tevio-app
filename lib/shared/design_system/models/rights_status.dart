import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';

enum RightsStatus {
  safe,
  detected,
  actionRequired,
  urgent,
  processing,
  completed,
  unknown,
}

extension RightsStatusX on RightsStatus {
  String get label {
    return switch (this) {
      RightsStatus.safe => '정상',
      RightsStatus.detected => '감지',
      RightsStatus.actionRequired => '확인 필요',
      RightsStatus.urgent => '긴급',
      RightsStatus.processing => '처리 중',
      RightsStatus.completed => '완료',
      RightsStatus.unknown => '확인 불가',
    };
  }

  Color get foreground {
    return switch (this) {
      RightsStatus.safe || RightsStatus.completed => TevioColors.mint,
      RightsStatus.detected || RightsStatus.processing => TevioColors.primary,
      RightsStatus.actionRequired => TevioColors.warning,
      RightsStatus.urgent => TevioColors.danger,
      RightsStatus.unknown => TevioColors.textSecondary,
    };
  }

  Color get background {
    return switch (this) {
      RightsStatus.safe ||
      RightsStatus.completed => TevioColors.successBackground,
      RightsStatus.detected ||
      RightsStatus.processing => TevioColors.primaryBackground,
      RightsStatus.actionRequired => TevioColors.warningBackground,
      RightsStatus.urgent => TevioColors.dangerBackground,
      RightsStatus.unknown => TevioColors.divider,
    };
  }

  IconData get icon {
    return switch (this) {
      RightsStatus.safe => Icons.shield_outlined,
      RightsStatus.detected => Icons.radar_outlined,
      RightsStatus.actionRequired => Icons.schedule_outlined,
      RightsStatus.urgent => Icons.warning_amber_rounded,
      RightsStatus.processing => Icons.sync_outlined,
      RightsStatus.completed => Icons.check_circle_outline,
      RightsStatus.unknown => Icons.help_outline,
    };
  }
}
