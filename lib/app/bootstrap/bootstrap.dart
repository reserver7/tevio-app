import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../core/config/app_environment.dart';
import '../app.dart';

Future<void> bootstrap(AppEnvironment environment) async {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (environment.sentryDsn.isNotEmpty) {
      Sentry.captureException(details.exception, stackTrace: details.stack);
    }
  };

  final app = ProviderScope(
    overrides: [appEnvironmentProvider.overrideWithValue(environment)],
    child: const TevioApp(),
  );

  if (environment.sentryDsn.isEmpty) {
    runApp(app);
    return;
  }

  await SentryFlutter.init((options) {
    options.dsn = environment.sentryDsn;
    options.environment = environment.name;
    options.tracesSampleRate = kReleaseMode ? 0.1 : 1.0;
  }, appRunner: () => runApp(app));
}
