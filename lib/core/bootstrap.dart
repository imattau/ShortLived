import 'di/locator.dart';

void bootstrapCore() {
  // After KeyService and SettingsService are registered
  Locator.I.ensureSigner();
}
