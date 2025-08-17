import 'dart:html' as html;
import 'dart:js_util' as js_util;

/// Guarded wrapper around [MediaSource.isTypeSupported].
///
/// Some browsers/environments don't expose `MediaSource` or its
/// `isTypeSupported` method. Calling it blindly can throw.
/// This helper performs feature detection and fails open (returns `true`)
/// so we don't block playback when unsure.
bool mediaSourceIsSupported(String mime) {
  if (!js_util.hasProperty(html.window, 'MediaSource')) {
    return true; // Can't check; assume supported.
  }
  try {
    final ms = js_util.getProperty(html.window, 'MediaSource');
    final result = js_util.callMethod<bool>(ms, 'isTypeSupported', [mime]);
    return result;
  } catch (_) {
    return true; // Fail open.
  }
}
