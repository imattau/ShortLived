import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart' as web;

import 'share_interface.dart';

class _WebShareShim implements ShareShim {
  JSObject get _navigator => web.window.navigator as JSObject;

  @override
  bool get isSupported => _navigator.hasProperty('share'.toJS).toDart;

  @override
  Future<bool> share({required String url, String? text, String? title}) async {
    if (!isSupported) return false;
    final data = JSObject();
    data.setProperty('url'.toJS, url.toJS);
    if (text != null) data.setProperty('text'.toJS, text.toJS);
    if (title != null) data.setProperty('title'.toJS, title.toJS);
    try {
      await (_navigator.callMethod('share'.toJS, [data].toJS)
              as JSPromise<JSAny?>)
          .toDart;
      return true;
    } catch (_) {
      return false;
    }
  }
}

final ShareShim shareShim = _WebShareShim();
