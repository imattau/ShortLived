import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as html;

class Capabilities {
  static bool get shareSupported {
    if (!kIsWeb) return false;
    try {
      final nav = html.window.navigator as dynamic;
      return nav != null && nav.canShare != null;
    } catch (_) {
      return false;
    }
  }
}
