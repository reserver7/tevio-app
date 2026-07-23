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
    return const Scaffold(
      backgroundColor: TevioColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TevioLogo(
                variant: TevioLogoVariant.symbol,
                size: 96,
                foregroundColor: Colors.white,
              ),
              SizedBox(height: TevioSpacing.lg),
              Text(
                '테비오',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.3,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: TevioSpacing.xs),
              Text(
                '구매 이후까지, 테비오',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.4,
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
