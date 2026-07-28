import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/design_system/tevio_design_system.dart';
import '../state/product_registration_result.dart';
import '../state/product_registration_session.dart';

enum _RegistrationStep {
  method,
  analyzing,
  productInfo,
  candidate,
  notifications,
  registering,
  complete,
}

enum _RegistrationMethod { camera, gallery, modelNumber, manual }

enum _RegistrationFailure {
  permissionDenied,
  imageCanceled,
  ocrFailed,
  modelNotFound,
  noCandidates,
  duplicatePossible,
  offline,
}

class ProductRegistrationPage extends ConsumerStatefulWidget {
  const ProductRegistrationPage({super.key});

  @override
  ConsumerState<ProductRegistrationPage> createState() =>
      _ProductRegistrationPageState();
}

class _ProductRegistrationPageState
    extends ConsumerState<ProductRegistrationPage> {
  _RegistrationStep _step = _RegistrationStep.method;
  _RegistrationMethod? _method;
  bool _recallAlert = true;
  bool _warrantyAlert = true;
  bool _returnAlert = true;
  _RegistrationFailure? _failure;
  bool _hasShownMockFailure = false;
  bool _showFieldErrors = false;
  String? _registeredProductId;
  String? _registeredProductName;
  int? _activeSession;
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelNumberController;
  late final TextEditingController _purchasedAtController;
  late final TextEditingController _purchaseStoreController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: '공기청정기');
    _brandController = TextEditingController(text: 'ABC');
    _modelNumberController = TextEditingController(text: 'ABC-123');
    _purchasedAtController = TextEditingController(text: '2026.07.23');
    _purchaseStoreController = TextEditingController(text: '브랜드 공식몰');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelNumberController.dispose();
    _purchasedAtController.dispose();
    _purchaseStoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(productRegistrationSessionProvider);
    if (_activeSession != session) {
      _activeSession = session;
      _resetLocalState();
    }

    return Scaffold(
      key: ValueKey('product-registration-$session'),
      appBar: const TevioAppBar(title: '제품 등록'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(TevioSpacing.lg),
          children: [
            if (_progressStep != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(_stepTitle, style: TevioTypography.titleLarge),
                  ),
                  Text(
                    '${_progressStep! + 1}/4',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: TevioColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TevioSpacing.md),
              TevioStepIndicator(currentStep: _progressStep!, totalSteps: 4),
              const SizedBox(height: TevioSpacing.xl),
            ],
            _buildStepContent(),
          ],
        ),
      ),
      bottomNavigationBar:
          _failure == null && _step != _RegistrationStep.registering
          ? SafeArea(
              minimum: const EdgeInsets.all(TevioSpacing.lg),
              child: Row(
                children: [
                  if (_step != _RegistrationStep.method &&
                      _step != _RegistrationStep.complete) ...[
                    Expanded(
                      child: TevioButton(
                        label: '이전',
                        icon: Icons.arrow_back_outlined,
                        variant: TevioButtonVariant.secondary,
                        onPressed: _goBack,
                      ),
                    ),
                    const SizedBox(width: TevioSpacing.sm),
                  ],
                  Expanded(
                    child: TevioButton(
                      label: _primaryActionLabel,
                      icon: _step == _RegistrationStep.complete
                          ? Icons.check
                          : Icons.arrow_forward_outlined,
                      onPressed: _canContinue ? _goNext : null,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  int? get _progressStep {
    return switch (_step) {
      _RegistrationStep.method || _RegistrationStep.complete => null,
      _RegistrationStep.analyzing || _RegistrationStep.productInfo => 0,
      _RegistrationStep.candidate => 1,
      _RegistrationStep.notifications => 2,
      _RegistrationStep.registering => 3,
    };
  }

  String get _stepTitle {
    return switch (_step) {
      _RegistrationStep.method => '등록 방식',
      _RegistrationStep.analyzing => '구매 정보 가져오기',
      _RegistrationStep.productInfo => '제품 정보 확인',
      _RegistrationStep.candidate => '제품 후보 확인',
      _RegistrationStep.notifications => '알림 선택',
      _RegistrationStep.registering => '제품 등록',
      _RegistrationStep.complete => '등록 완료',
    };
  }

  Widget _buildStepContent() {
    return switch (_step) {
      _RegistrationStep.method => _MethodStep(
        selectedMethod: _method,
        onSelected: (method) {
          setState(() {
            _method = method;
          });
        },
      ),
      _RegistrationStep.analyzing => _AnalysisStep(
        method: _method,
        failure: _failure,
        onRetryPressed: () {
          setState(() {
            _failure = null;
            _step = _RegistrationStep.productInfo;
          });
        },
      ),
      _RegistrationStep.productInfo => _ProductInfoStep(
        method: _method,
        nameController: _nameController,
        brandController: _brandController,
        modelNumberController: _modelNumberController,
        purchasedAtController: _purchasedAtController,
        purchaseStoreController: _purchaseStoreController,
        showErrors: _showFieldErrors,
        onChanged: _handleProductInfoChanged,
      ),
      _RegistrationStep.candidate => _CandidateStep(input: _registrationInput),
      _RegistrationStep.notifications => _NotificationOptionsStep(
        recallAlert: _recallAlert,
        warrantyAlert: _warrantyAlert,
        returnAlert: _returnAlert,
        onRecallChanged: (value) => setState(() => _recallAlert = value),
        onWarrantyChanged: (value) => setState(() => _warrantyAlert = value),
        onReturnChanged: (value) => setState(() => _returnAlert = value),
      ),
      _RegistrationStep.registering => _RegisteringStep(
        input: _registrationInput.normalized(),
      ),
      _RegistrationStep.complete => TevioCompletionView(
        title: '${_registeredProductName ?? '제품'} 등록이 완료됐어요.',
        description: '이제 테비오가 이 제품의 권리를 계속 확인할게요.',
      ),
    };
  }

  bool get _canContinue {
    return switch (_step) {
      _RegistrationStep.method => _method != null,
      _RegistrationStep.analyzing => true,
      _RegistrationStep.productInfo => true,
      _RegistrationStep.candidate => true,
      _RegistrationStep.notifications => true,
      _RegistrationStep.registering => false,
      _RegistrationStep.complete => true,
    };
  }

  String get _primaryActionLabel {
    return switch (_step) {
      _RegistrationStep.method =>
        _method == _RegistrationMethod.camera
            ? '촬영하기'
            : _method == _RegistrationMethod.gallery
            ? '이미지 선택'
            : '제품 정보 입력',
      _RegistrationStep.analyzing => '분석 시작',
      _RegistrationStep.productInfo => '후보 확인',
      _RegistrationStep.candidate => '알림 선택',
      _RegistrationStep.notifications => '등록하기',
      _RegistrationStep.registering => '등록 중',
      _RegistrationStep.complete => '확인',
    };
  }

  void _goBack() {
    setState(() {
      _failure = null;
      _step =
          _RegistrationStep.values[_RegistrationStep.values.indexOf(_step) - 1];
    });
  }

  void _goNext() {
    if (_step == _RegistrationStep.complete) {
      ref.read(productRegistrationSessionProvider.notifier).reset();
      if (_registeredProductId != null) {
        context.go('/products/$_registeredProductId');
      }
      return;
    }

    if (_step == _RegistrationStep.method) {
      setState(() {
        _step = switch (_method) {
          _RegistrationMethod.camera ||
          _RegistrationMethod.gallery => _RegistrationStep.analyzing,
          _RegistrationMethod.modelNumber ||
          _RegistrationMethod.manual => _RegistrationStep.productInfo,
          null => _RegistrationStep.method,
        };
      });
      return;
    }

    if (_step == _RegistrationStep.analyzing) {
      if (_hasShownMockFailure) {
        setState(() {
          _step = _RegistrationStep.productInfo;
        });
        return;
      }

      setState(() {
        _failure = _RegistrationFailure.ocrFailed;
        _hasShownMockFailure = true;
      });
      return;
    }

    if (_step == _RegistrationStep.productInfo && !_registrationInput.isValid) {
      setState(() {
        _showFieldErrors = true;
      });
      return;
    }

    if (_step == _RegistrationStep.notifications) {
      _submitRegistration();
      return;
    }

    setState(() {
      _showFieldErrors = false;
      _step =
          _RegistrationStep.values[_RegistrationStep.values.indexOf(_step) + 1];
    });
  }

  Future<void> _submitRegistration() async {
    if (!_registrationInput.isValid) {
      setState(() {
        _step = _RegistrationStep.productInfo;
        _showFieldErrors = true;
      });
      return;
    }

    setState(() {
      _step = _RegistrationStep.registering;
    });

    await Future<void>.delayed(TevioMotion.slow);
    if (!mounted) {
      return;
    }

    final result = ref
        .read(productRegistrationResultProvider)
        .registerProduct(_registrationInput);

    result.when(
      success: (product) {
        setState(() {
          _registeredProductId = product.id;
          _registeredProductName = product.name;
          _step = _RegistrationStep.complete;
        });
      },
      failure: (failure) {
        setState(() {
          _step = _RegistrationStep.notifications;
        });
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(failure.message)));
      },
    );
  }

  void _resetLocalState() {
    _step = _RegistrationStep.method;
    _method = null;
    _recallAlert = true;
    _warrantyAlert = true;
    _returnAlert = true;
    _failure = null;
    _hasShownMockFailure = false;
    _showFieldErrors = false;
    _registeredProductId = null;
    _registeredProductName = null;
    _nameController.text = '공기청정기';
    _brandController.text = 'ABC';
    _modelNumberController.text = 'ABC-123';
    _purchasedAtController.text = '2026.07.23';
    _purchaseStoreController.text = '브랜드 공식몰';
  }

  ProductRegistrationInput get _registrationInput {
    return ProductRegistrationInput(
      name: _nameController.text,
      brand: _brandController.text,
      modelNumber: _modelNumberController.text,
      purchasedAt: _purchasedAtController.text,
      purchaseStore: _purchaseStoreController.text,
      recallAlert: _recallAlert,
      warrantyAlert: _warrantyAlert,
      returnAlert: _returnAlert,
    );
  }

  void _handleProductInfoChanged() {
    final shouldShowErrors = !_registrationInput.isValid;

    if (_showFieldErrors == shouldShowErrors) {
      return;
    }

    setState(() {
      _showFieldErrors = shouldShowErrors;
    });
  }
}

class _MethodStep extends StatelessWidget {
  const _MethodStep({required this.selectedMethod, required this.onSelected});

  final _RegistrationMethod? selectedMethod;
  final ValueChanged<_RegistrationMethod> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('어떤 방식으로 등록할까요?', style: TevioTypography.titleLarge),
        const SizedBox(height: TevioSpacing.xs),
        Text(
          '가장 편한 방법을 선택하면 필요한 정보만 차례로 확인할게요.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: TevioSpacing.xl),
        _MethodTile(
          method: _RegistrationMethod.camera,
          selectedMethod: selectedMethod,
          icon: Icons.camera_alt_outlined,
          title: '영수증 촬영',
          description: '구매 정보를 빠르게 읽어올 준비를 합니다.',
          onSelected: onSelected,
        ),
        const SizedBox(height: TevioSpacing.sm),
        _MethodTile(
          method: _RegistrationMethod.gallery,
          selectedMethod: selectedMethod,
          icon: Icons.image_outlined,
          title: '앨범에서 선택',
          description: '저장된 영수증 또는 주문 화면을 사용합니다.',
          onSelected: onSelected,
        ),
        const SizedBox(height: TevioSpacing.sm),
        _MethodTile(
          method: _RegistrationMethod.modelNumber,
          selectedMethod: selectedMethod,
          icon: Icons.keyboard_alt_outlined,
          title: '모델번호 직접 입력',
          description: '제품 라벨의 모델번호로 권리 정보를 확인합니다.',
          onSelected: onSelected,
        ),
        const SizedBox(height: TevioSpacing.sm),
        _MethodTile(
          method: _RegistrationMethod.manual,
          selectedMethod: selectedMethod,
          icon: Icons.edit_note_outlined,
          title: '제품 직접 등록',
          description: '제품명, 구매일, 구매처를 직접 입력합니다.',
          onSelected: onSelected,
        ),
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.method,
    required this.selectedMethod,
    required this.icon,
    required this.title,
    required this.description,
    required this.onSelected,
  });

  final _RegistrationMethod method;
  final _RegistrationMethod? selectedMethod;
  final IconData icon;
  final String title;
  final String description;
  final ValueChanged<_RegistrationMethod> onSelected;

  @override
  Widget build(BuildContext context) {
    return TevioSelectionTile(
      icon: icon,
      title: title,
      description: description,
      selected: selectedMethod == method,
      onTap: () => onSelected(method),
    );
  }
}

class _AnalysisStep extends StatelessWidget {
  const _AnalysisStep({
    required this.method,
    required this.failure,
    required this.onRetryPressed,
  });

  final _RegistrationMethod? method;
  final _RegistrationFailure? failure;
  final VoidCallback onRetryPressed;

  @override
  Widget build(BuildContext context) {
    if (failure != null) {
      final copy = _RegistrationFailureCopy.from(failure!);

      return TevioErrorState(
        title: copy.title,
        description: copy.description,
        actionLabel: copy.action,
        onRetryPressed: onRetryPressed,
      );
    }

    final title = method == _RegistrationMethod.camera
        ? '영수증을 촬영하면 정보를 읽어올게요'
        : '선택한 이미지에서 구매 정보를 읽어올게요';

    final description = method == _RegistrationMethod.camera
        ? '사진이 선명할수록 제품명, 구매일, 구매처를 더 정확히 확인할 수 있어요.'
        : '주문 내역 화면이나 영수증 이미지가 가장 정확합니다.';

    return TevioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              color: TevioColors.primaryBackground,
              borderRadius: TevioRadius.fullBorder,
            ),
            child: Padding(
              padding: EdgeInsets.all(TevioSpacing.md),
              child: Icon(
                Icons.document_scanner_outlined,
                color: TevioColors.primary,
              ),
            ),
          ),
          const SizedBox(height: TevioSpacing.md),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: TevioSpacing.xs),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: TevioSpacing.md),
          Text(
            'Mock에서는 첫 분석 시도 후 실패 상태를 보여주고, 직접 입력으로 이어집니다.',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: TevioColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _ProductInfoStep extends StatelessWidget {
  const _ProductInfoStep({
    required this.method,
    required this.nameController,
    required this.brandController,
    required this.modelNumberController,
    required this.purchasedAtController,
    required this.purchaseStoreController,
    required this.showErrors,
    required this.onChanged,
  });

  final _RegistrationMethod? method;
  final TextEditingController nameController;
  final TextEditingController brandController;
  final TextEditingController modelNumberController;
  final TextEditingController purchasedAtController;
  final TextEditingController purchaseStoreController;
  final bool showErrors;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final helperText = switch (method) {
      _RegistrationMethod.camera ||
      _RegistrationMethod.gallery => '읽지 못한 정보만 직접 보완해 주세요.',
      _RegistrationMethod.modelNumber => '제품 라벨에 적힌 모델번호를 기준으로 확인합니다.',
      _RegistrationMethod.manual => '알 수 있는 정보만 먼저 입력해도 등록할 수 있어요.',
      null => '제품 정보를 입력해 주세요.',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TevioSectionHeader(title: '제품 정보'),
        const SizedBox(height: TevioSpacing.sm),
        Text(helperText, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: TevioSpacing.lg),
        const _FieldLabel('제품명'),
        TextField(
          controller: nameController,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: '예: 공기청정기',
            errorText: _requiredErrorText(nameController, '제품명을 입력해 주세요.'),
          ),
        ),
        const SizedBox(height: TevioSpacing.md),
        const _FieldLabel('제조사'),
        TextField(
          controller: brandController,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: '예: ABC',
            errorText: _requiredErrorText(brandController, '제조사를 입력해 주세요.'),
          ),
        ),
        const SizedBox(height: TevioSpacing.md),
        const _FieldLabel('모델번호'),
        TextField(
          controller: modelNumberController,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: '예: ABC-123',
            errorText: _requiredErrorText(
              modelNumberController,
              '모델번호를 입력해 주세요.',
            ),
          ),
        ),
        const SizedBox(height: TevioSpacing.md),
        const _FieldLabel('구매일'),
        TextField(
          controller: purchasedAtController,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(hintText: '예: 2026.07.23'),
        ),
        const SizedBox(height: TevioSpacing.md),
        const _FieldLabel('구매처'),
        TextField(
          controller: purchaseStoreController,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(hintText: '예: 브랜드 공식몰'),
        ),
      ],
    );
  }

  String? _requiredErrorText(TextEditingController controller, String message) {
    if (!showErrors || controller.text.trim().isNotEmpty) {
      return null;
    }

    return message;
  }
}

class _RegistrationFailureCopy {
  const _RegistrationFailureCopy({
    required this.title,
    required this.description,
    required this.action,
  });

  final String title;
  final String description;
  final String action;

  factory _RegistrationFailureCopy.from(_RegistrationFailure failure) {
    return switch (failure) {
      _RegistrationFailure.permissionDenied => const _RegistrationFailureCopy(
        title: '카메라 권한이 필요해요',
        description: '영수증을 촬영하려면 카메라 접근 권한을 허용해야 합니다.',
        action: '권한 설정 확인',
      ),
      _RegistrationFailure.imageCanceled => const _RegistrationFailureCopy(
        title: '이미지 선택이 취소됐어요',
        description: '앨범에서 영수증이나 주문 화면을 다시 선택할 수 있어요.',
        action: '이미지 다시 선택',
      ),
      _RegistrationFailure.ocrFailed => const _RegistrationFailureCopy(
        title: '영수증을 읽지 못했어요',
        description: '사진이 흐리거나 일부 정보가 가려져 있으면 직접 입력이 필요합니다.',
        action: '직접 입력으로 계속',
      ),
      _RegistrationFailure.modelNotFound => const _RegistrationFailureCopy(
        title: '모델번호를 확인하지 못했어요',
        description: '제품 라벨의 모델번호를 다시 확인하거나 제품명을 입력해 주세요.',
        action: '모델번호 다시 입력',
      ),
      _RegistrationFailure.noCandidates => const _RegistrationFailureCopy(
        title: '제품 후보가 없어요',
        description: '입력한 정보와 일치하는 제품 후보를 찾지 못했습니다.',
        action: '제품 직접 등록',
      ),
      _RegistrationFailure.duplicatePossible => const _RegistrationFailureCopy(
        title: '이미 등록한 제품일 수 있어요',
        description: '같은 모델번호와 구매일의 제품이 이미 등록되어 있습니다.',
        action: '기존 제품 확인',
      ),
      _RegistrationFailure.offline => const _RegistrationFailureCopy(
        title: '연결 상태를 확인해 주세요',
        description: '네트워크가 연결되면 리콜과 보증 정보를 다시 확인할 수 있어요.',
        action: '다시 시도',
      ),
    };
  }
}

class _CandidateStep extends StatelessWidget {
  const _CandidateStep({required this.input});

  final ProductRegistrationInput input;

  @override
  Widget build(BuildContext context) {
    final normalizedInput = input.normalized();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TevioSectionHeader(title: '제품 후보 확인'),
        const SizedBox(height: TevioSpacing.sm),
        TevioProductCard(
          name: normalizedInput.name,
          brand: normalizedInput.brand,
          modelNumber: normalizedInput.modelNumber,
          purchasedAt: normalizedInput.purchasedAt,
          warrantyText: '365일 예상',
          status: RightsStatus.detected,
          summary: '입력한 모델번호와 가장 유사한 제품 후보예요.',
        ),
        const SizedBox(height: TevioSpacing.sm),
        const TevioCard(
          child: Text(
            'OCR 결과가 확실하지 않으면 자동 확정하지 않고 후보를 확인합니다.',
            style: TevioTypography.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _NotificationOptionsStep extends StatelessWidget {
  const _NotificationOptionsStep({
    required this.recallAlert,
    required this.warrantyAlert,
    required this.returnAlert,
    required this.onRecallChanged,
    required this.onWarrantyChanged,
    required this.onReturnChanged,
  });

  final bool recallAlert;
  final bool warrantyAlert;
  final bool returnAlert;
  final ValueChanged<bool> onRecallChanged;
  final ValueChanged<bool> onWarrantyChanged;
  final ValueChanged<bool> onReturnChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TevioSectionHeader(title: '알림 항목'),
        const SizedBox(height: TevioSpacing.sm),
        TevioCard(
          child: Column(
            children: [
              SwitchListTile(
                value: recallAlert,
                onChanged: onRecallChanged,
                title: const Text('리콜과 무상수리'),
                subtitle: const Text('안전 문제와 공식 조치가 감지되면 알려드려요.'),
              ),
              const Divider(height: TevioSpacing.xl),
              SwitchListTile(
                value: warrantyAlert,
                onChanged: onWarrantyChanged,
                title: const Text('보증 만료'),
                subtitle: const Text('무상보증 종료 전 필요한 시점에 알려드려요.'),
              ),
              const Divider(height: TevioSpacing.xl),
              SwitchListTile(
                value: returnAlert,
                onChanged: onReturnChanged,
                title: const Text('반품과 교환 가능 기간'),
                subtitle: const Text('구매 이후 놓치기 쉬운 기한을 확인해요.'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RegisteringStep extends StatelessWidget {
  const _RegisteringStep({required this.input});

  final ProductRegistrationInput input;

  @override
  Widget build(BuildContext context) {
    return TevioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              color: TevioColors.primaryBackground,
              borderRadius: TevioRadius.fullBorder,
            ),
            child: Padding(
              padding: EdgeInsets.all(TevioSpacing.md),
              child: Icon(Icons.sync_outlined, color: TevioColors.primary),
            ),
          ),
          const SizedBox(height: TevioSpacing.md),
          Text('제품 정보를 등록하고 있어요', style: TevioTypography.titleMedium),
          const SizedBox(height: TevioSpacing.xs),
          Text(
            '모델번호, 구매일, 알림 설정을 저장하고 첫 권리 상태를 확인합니다.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: TevioSpacing.md),
          const TevioInfoRow(label: '리콜 확인', value: '진행 중'),
          const Divider(height: TevioSpacing.xl),
          const TevioInfoRow(label: '보증 계산', value: '대기'),
          const Divider(height: TevioSpacing.xl),
          TevioInfoRow(label: '알림 설정', value: input.alertSummary),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TevioSpacing.xs),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
