import 'app/app_env.dart';
import 'main.dart';


Future<void> main() async {
  EnvironmentConfig.init(EnvironmentType.production);

  await runMainApp();
}