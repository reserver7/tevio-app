import 'dart:io';

void main(List<String> args) {
  if (args.length < 2) {
    stderr.writeln('Usage: dart run tool/changelog.dart <type> <message>');
    exitCode = 64;
    return;
  }
  final type = args.first;
  final message = args.skip(1).join(' ');
  final file = File('docs/design-system/CHANGELOG.md');
  final current = file.existsSync() ? file.readAsStringSync() : '# Changelog\n';
  final date = DateTime.now().toIso8601String().substring(0, 10);
  final entry = '\n## $date\n\n- **$type**: $message\n';
  file.writeAsStringSync(current.trimRight() + entry);
}
