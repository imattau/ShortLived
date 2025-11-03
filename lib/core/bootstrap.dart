import 'di/locator.dart';
import '../web/pwa/pwa_service.dart';
import '../services/nostr/metadata_service.dart';

void bootstrapCore() {
  // After KeyService and SettingsService are registered
  if (Locator.I.tryGet<PwaService>() == null) {
    Locator.I.put<PwaService>(getPwaService());
  }
  if (!Locator.I.contains<MetadataService>()) {
    Locator.I.put<MetadataService>(MetadataService());
  }
  Locator.I.ensureSigner();
}
