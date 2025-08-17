import 'capabilities_io.dart'
    if (dart.library.html) 'capabilities_web.dart' as impl;

class Capabilities {
  static bool get shareSupported => impl.shareSupported;
}
