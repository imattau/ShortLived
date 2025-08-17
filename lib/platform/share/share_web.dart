import 'dart:js_util' as jsu;
import 'dart:html' as html;

import 'share_interface.dart';

class _WebShareShim implements ShareShim {
  @override
  bool get isSupported => jsu.hasProperty(html.window.navigator, 'share');

  @override
  Future<bool> share({required String url, String? text, String? title}) async {
    if (!isSupported) return false;
    try {
      await jsu.promiseToFuture(jsu.callMethod(
        html.window.navigator,
        'share',
        [
          {
            if (title != null) 'title': title,
            if (text != null) 'text': text,
            'url': url,
          }
        ],
      ));
      return true;
    } catch (_) {
      return false;
    }
  }
}

final ShareShim shareShim = _WebShareShim();
