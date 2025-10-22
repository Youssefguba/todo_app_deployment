import 'package:todo_app_v2/main.dart';

import 'app/app_env.dart';

Future<void> main() async {
  EnvironmentConfig.init(EnvironmentType.staging);

  await runMainApp();
}
