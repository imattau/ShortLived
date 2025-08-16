import 'dart:html' as html;

/// Unregister all service workers in debug web to avoid stale caches while developing.
Future<void> killServiceWorkersInDebug() async {
  try {
    final regs = await html.window.navigator.serviceWorker?.getRegistrations() ?? const [];
    for (final r in regs) {
      await r.unregister();
    }
    // Best-effort: clear Cache Storage keys
    final cacheKeys = await html.window.caches.keys();
    for (final k in cacheKeys) {
      await html.window.caches.delete(k);
    }
  } catch (_) {
    // ignore — never block startup
  }
}
