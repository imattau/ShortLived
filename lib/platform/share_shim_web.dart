// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as jsu;

import 'share_shim.dart' hide shareShim;
export 'share_shim.dart' hide shareShim;

final ShareShim _shareShim = _WebShareShim();

ShareShim get shareShim => _shareShim;

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
          <String, dynamic>{
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
