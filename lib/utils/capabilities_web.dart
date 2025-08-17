// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

bool get shareSupported {
  try {
    final nav = html.window.navigator as dynamic;
    return nav != null && nav.canShare != null;
  } catch (_) {
    return false;
  }
}
