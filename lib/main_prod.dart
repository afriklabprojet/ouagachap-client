import 'core/config/app_config.dart';
import 'main.dart' as app;

void main() {
  AppConfig.init(Environment.prod);
  app.main();
}
