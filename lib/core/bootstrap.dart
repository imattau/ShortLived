import 'di/locator.dart';
import '../web/pwa/pwa_service.dart';

void bootstrapCore() {
  // After KeyService and SettingsService are registered
  if (Locator.I.tryGet<PwaService>() == null) {
    Locator.I.put<PwaService>(getPwaService());
  }
  Locator.I.ensureSigner();
}
