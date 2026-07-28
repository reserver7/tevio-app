import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/design_system/tevio_design_system.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  var _currentIndex = 0;

  static const _pages = [
    _OnboardingContent(
      icon: Icons.receipt_long_outlined,
      title: '제품을 등록하면',
      description: '영수증과 제품 정보를 간편하게 모아 관리할 수 있어요.',
    ),
    _OnboardingContent(
      icon: Icons.radar_outlined,
      title: '놓친 권리를 감지하고',
      description: '리콜, 보증 만료, 반품과 교환 가능 시점을 테비오가 확인해요.',
    ),
    _OnboardingContent(
      icon: Icons.near_me_outlined,
      title: '필요한 행동을 알려드려요',
      description: '지금 해야 할 일을 판단하고 A/S, 교환, 반품까지 연결해요.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continue() {
    if (_currentIndex == _pages.length - 1) {
      context.go('/login');
      return;
    }

    _controller.nextPage(
      duration: TevioMotion.normal,
      curve: TevioMotion.standardCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(TevioSpacing.lg),
              child: Row(
                children: [
                  const TevioLogo(variant: TevioLogoVariant.symbol, size: 32),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('건너뛰기'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  return _OnboardingPageBody(content: _pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TevioSpacing.lg,
                0,
                TevioSpacing.lg,
                TevioSpacing.lg,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var index = 0; index < _pages.length; index++)
                        _PageDot(isActive: index == _currentIndex),
                    ],
                  ),
                  const SizedBox(height: TevioSpacing.lg),
                  TevioButton(
                    label: _currentIndex == _pages.length - 1
                        ? '테비오 시작하기'
                        : '다음',
                    onPressed: _continue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageBody extends StatelessWidget {
  const _OnboardingPageBody({required this.content});

  final _OnboardingContent content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TevioSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              color: TevioColors.primaryBackground,
              borderRadius: TevioRadius.largeBorder,
            ),
            child: Padding(
              padding: const EdgeInsets.all(TevioSpacing.xxl),
              child: Icon(content.icon, size: 56, color: TevioColors.primary),
            ),
          ),
          const SizedBox(height: TevioSpacing.xxl),
          Text(
            content.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: TevioSpacing.sm),
          Text(
            content.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _PageDot extends StatelessWidget {
  const _PageDot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: TevioMotion.normal,
      width: isActive ? 20 : 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? TevioColors.primary : TevioColors.border,
        borderRadius: TevioRadius.fullBorder,
      ),
    );
  }
}

class _OnboardingContent {
  const _OnboardingContent({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
