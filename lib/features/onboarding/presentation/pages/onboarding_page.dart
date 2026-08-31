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
      eyebrow: '등록',
      title: '구매 정보를 한 번만 남기세요',
      description: '영수증, 모델번호, 직접 입력 중 편한 방법으로 시작할 수 있어요.',
      highlights: ['제품과 구매일을 함께 보관', '입력한 내용은 등록 전에 다시 확인'],
    ),
    _OnboardingContent(
      eyebrow: '확인',
      title: '놓치기 쉬운 권리를 모아 확인해요',
      description: '리콜과 보증, 반품·교환 기간을 제품별로 정리합니다.',
      highlights: ['긴급한 변화만 우선 안내', '정상 상태와 확인 필요 상태를 구분'],
    ),
    _OnboardingContent(
      eyebrow: '행동',
      title: '필요한 순간에 다음 행동을 알려드려요',
      description: '확인에서 끝나지 않고 A/S, 교환, 반품의 진행 기록까지 이어집니다.',
      highlights: ['제품 상태에 맞는 대표 행동', '처리 과정과 완료 기록을 한곳에서 관리'],
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
                  TevioTextAction(
                    label: '건너뛰기',
                    onPressed: () => context.go('/login'),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TevioPageIntro(
            eyebrow: content.eyebrow,
            title: content.title,
            description: content.description,
          ),
          const SizedBox(height: TevioSpacing.xxl),
          TevioListSection(
            children: [
              for (final highlight in content.highlights)
                _OnboardingHighlight(text: highlight),
            ],
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
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.highlights,
  });

  final String eyebrow;
  final String title;
  final String description;
  final List<String> highlights;
}

class _OnboardingHighlight extends StatelessWidget {
  const _OnboardingHighlight({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TevioSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: TevioColors.mint, size: 22),
          const SizedBox(width: TevioSpacing.md),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
