import 'package:flutter/material.dart';

import '../../../../shared/design_system/tevio_design_system.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TevioAppBar(title: '알림', automaticallyImplyLeading: false),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TevioSpacing.lg),
          children: const [
            TevioSectionHeader(title: '즉시 확인'),
            SizedBox(height: TevioSpacing.sm),
            TevioRightsCard(
              status: RightsStatus.urgent,
              productName: '무선청소기',
              title: '리콜 알림',
              description: '등록하신 제품과 유사한 리콜 정보가 있어요. 지금 확인해보세요.',
              dueText: '지금',
              actionLabel: '리콜 내용 확인',
            ),
            SizedBox(height: TevioSpacing.lg),
            TevioSectionHeader(title: '기한 임박'),
            SizedBox(height: TevioSpacing.sm),
            TevioRightsCard(
              status: RightsStatus.actionRequired,
              productName: '노트북',
              title: '보증 만료 예정',
              description: '보증 만료 전 필요한 서류와 점검 항목을 확인하세요.',
              dueText: '28일 남음',
              actionLabel: '보증 정보 확인',
            ),
          ],
        ),
      ),
    );
  }
}
