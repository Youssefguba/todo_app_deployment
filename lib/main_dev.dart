import 'app/app_env.dart';
import 'main.dart';

Future<void> main() async {
  // Set environment before running the app
  EnvironmentConfig.init(EnvironmentType.development);

  await runMainApp();
}