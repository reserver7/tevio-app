class TevioFailure {
  const TevioFailure({required this.message, this.recoveryLabel = '다시 시도'});

  final String message;
  final String recoveryLabel;
}
