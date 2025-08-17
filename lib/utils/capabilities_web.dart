import 'dart:html' as html;

bool get shareSupported {
  try {
    final nav = html.window.navigator as dynamic;
    return nav != null && nav.canShare != null;
  } catch (_) {
    return false;
  }
}
