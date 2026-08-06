import 'dart:io';

void main() {
  final required = [
    'lib/shared/design_system/tokens/tevio_colors.dart',
    'lib/shared/design_system/tokens/tevio_dimensions.dart',
    'lib/shared/design_system/tokens/tevio_spacing.dart',
    'lib/shared/design_system/tokens/tevio_typography.dart',
    'lib/shared/design_system/tevio_design_system.dart',
  ];
  final missing = required.where((path) => !File(path).existsSync()).toList();
  if (missing.isNotEmpty) {
    stderr.writeln(
      'Missing design-system contract files: ${missing.join(', ')}',
    );
    exitCode = 1;
    return;
  }
  stdout.writeln('Design-system token contract is valid.');
}
