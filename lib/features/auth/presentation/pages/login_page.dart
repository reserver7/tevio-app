import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/design_system/tevio_design_system.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TevioPageScrollView(
        padding: const EdgeInsets.fromLTRB(
          TevioSpacing.lg,
          TevioSpacing.xl,
          TevioSpacing.lg,
          TevioSpacing.xl,
        ),
        children: [
          const SizedBox(height: TevioSpacing.xl),
          const TevioLogo(variant: TevioLogoVariant.symbol, size: 48),
          const SizedBox(height: TevioSpacing.xxl),
          const TevioPageIntro(
            eyebrow: 'TEVIO',
            title: '구매 이후를 놓치지 않게',
            description: '제품을 등록하면 필요한 권리와 다음 행동을 한곳에서 확인할 수 있어요.',
          ),
          const SizedBox(height: TevioSpacing.xl),
          TevioButton(label: '둘러보기로 시작', onPressed: () => context.go('/home')),
          const SizedBox(height: TevioSpacing.md),
          Text(
            '계정 동기화는 준비 중이에요. 지금 등록한 제품과 설정은 이 기기에 저장됩니다.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
