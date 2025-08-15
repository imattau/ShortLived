import 'pwa_service_base.dart';
import 'pwa_service_stub.dart' if (dart.library.html) 'pwa_service_web.dart';

export 'pwa_service_base.dart';
export 'pwa_service_stub.dart' show PwaServiceStub;

PwaService getPwaService() => createPwaService();
