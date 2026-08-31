import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/design_system/tevio_design_system.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TevioColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TevioSpacing.xl),
          child: Stack(
            children: [
              const Center(
                child: TevioLogo(
                  variant: TevioLogoVariant.symbol,
                  size: 96,
                  foregroundColor: TevioColors.white,
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '구매 이후의 권리를\n필요한 행동으로 연결합니다.',
                      style: TevioTypography.titleLarge.copyWith(
                        color: TevioColors.white,
                      ),
                    ),
                    const SizedBox(height: TevioSpacing.sm),
                    Text(
                      'TEVIO',
                      style: TevioTypography.label.copyWith(
                        color: TevioColors.whiteMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
