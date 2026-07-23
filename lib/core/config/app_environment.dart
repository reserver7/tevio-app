import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Environment { development, staging, production }

class AppEnvironment {
  const AppEnvironment({
    required this.type,
    required this.apiBaseUrl,
    required this.sentryDsn,
  });

  factory AppEnvironment.fromDartDefine() {
    const rawEnv = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'development',
    );

    final type = switch (rawEnv) {
      'production' => Environment.production,
      'staging' => Environment.staging,
      _ => Environment.development,
    };

    return AppEnvironment(
      type: type,
      apiBaseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://api.dev.tevio.app',
      ),
      sentryDsn: const String.fromEnvironment('SENTRY_DSN'),
    );
  }

  final Environment type;
  final String apiBaseUrl;
  final String sentryDsn;

  String get name => type.name;
}

final appEnvironmentProvider = Provider<AppEnvironment>((ref) {
  throw StateError('AppEnvironment was not initialized.');
});
