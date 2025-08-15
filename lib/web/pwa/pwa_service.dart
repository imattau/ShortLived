import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

abstract class PwaService {
  ValueNotifier<bool> get installAvailable;
  Future<bool> promptInstall();
}

class PwaServiceStub implements PwaService {
  @override final installAvailable = ValueNotifier<bool>(false);
  @override Future<bool> promptInstall() async => false;
}

typedef _PromptFn = Future<Map<String, dynamic>> Function();

PwaService getPwaService() => kIsWeb ? PwaServiceWeb() : PwaServiceStub();

/// Web-only implementation (guarded by kIsWeb at construction site)
class PwaServiceWeb implements PwaService {
  @override final installAvailable = ValueNotifier<bool>(false);
  _PromptFn? _prompt;

  PwaServiceWeb() {
    // Lazily bind to JS without importing dart:html in tests.
    // Use dynamic to avoid analyzer errors on non-web.
    // ignore: avoid_dynamic_calls
    final w = (Object? Function())(() => (globalThis))(); // HACK: let Flutter tree-shake this; see below
    try {
      // ignore: undefined_identifier
      // On web, "window" exists; on VM/tests, this throws and we fall back.
      // dynamic win = window;
      // Instead, use js util free approach:
      // Listen for the custom DOM event to flip availability.
      // This indirect access keeps VM tests happy.
    } catch (_) {}
    // Use a post-frame callback to attach via dart:html only when web.
    if (kIsWeb) {
      _bindDom();
    }
  }

  Future<void> _bindDom() async {
    // ignore: avoid_web_libraries_in_flutter
    import 'dart:html' as html;
    html.window.addEventListener('__pwa-install-available', (_) {
      installAvailable.value = true;
    });
    _prompt = () async {
      final res = await html.window.callMethod('__pwaPrompt', const []) as Object?;
      final map = (res is Map) ? Map<String, dynamic>.from(res) : <String, dynamic>{ 'ok': false };
      if (map['ok'] == true) installAvailable.value = false;
      return map;
    };
  }

  @override
  Future<bool> promptInstall() async {
    final f = _prompt;
    if (f == null) return false;
    final res = await f();
    return res['ok'] == true;
  }
}
