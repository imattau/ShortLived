// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Unregister all service workers in debug web to avoid stale caches while developing.
Future<void> killServiceWorkersInDebug() async {
  try {
    final regs = await html.window.navigator.serviceWorker?.getRegistrations() ?? const [];
    for (final r in regs) {
      await r.unregister();
    }
    // Best-effort: clear Cache Storage keys
    final caches = html.window.caches;
    final cacheKeys = caches != null ? await caches.keys() : const <String>[];
    for (final k in cacheKeys) {
      await caches?.delete(k);
    }
  } catch (_) {
    // ignore — never block startup
  }
}
