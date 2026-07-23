import 'package:flutter/widgets.dart';

import 'app/bootstrap/bootstrap.dart';
import 'core/config/app_environment.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await bootstrap(AppEnvironment.fromDartDefine());
}
