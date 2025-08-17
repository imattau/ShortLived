import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

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
