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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TevioLogo(
                variant: TevioLogoVariant.symbol,
                size: 96,
                foregroundColor: TevioColors.white,
              ),
              const SizedBox(height: TevioSpacing.lg),
              Text(
                '테비오',
                style: TevioTypography.display.copyWith(
                  color: TevioColors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: TevioSpacing.xs),
              Text(
                '구매 이후까지, 테비오',
                style: TevioTypography.bodyMedium.copyWith(
                  color: TevioColors.whiteMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
