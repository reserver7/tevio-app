import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/design_system/tevio_design_system.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TevioSpacing.lg),
          children: [
            const SizedBox(height: TevioSpacing.xl),
            const TevioLogo(variant: TevioLogoVariant.symbol, size: 48),
            const SizedBox(height: TevioSpacing.xxl),
            Text(
              '구매 이후의 모든 권리,\n테비오가 먼저 챙깁니다.',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: TevioSpacing.sm),
            Text(
              '구매한 제품을 등록하고 리콜, 보증, A/S 정보를 한곳에서 확인하세요.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: TevioSpacing.xxl),
            TevioButton(
              label: '간편 로그인 준비 중',
              icon: Icons.lock_outline,
              onPressed: null,
            ),
            const SizedBox(height: TevioSpacing.sm),
            TevioButton(
              label: '로그인 없이 둘러보기',
              icon: Icons.arrow_forward_outlined,
              variant: TevioButtonVariant.secondary,
              onPressed: () => context.go('/home'),
            ),
            const SizedBox(height: TevioSpacing.xl),
            const Text(
              '계속하면 테비오의 이용약관과 개인정보 처리방침에 동의한 것으로 간주됩니다.',
              style: TevioTypography.label,
            ),
          ],
        ),
      ),
    );
  }
}
