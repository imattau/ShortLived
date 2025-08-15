// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'package:flutter/material.dart';

import 'pwa_service_base.dart';

class PwaServiceWeb implements PwaService {
  @override
  final installAvailable = ValueNotifier<bool>(false);

  PwaServiceWeb() {
    html.window.addEventListener('__pwa-install-available', (_) {
      installAvailable.value = true;
    });
  }

  @override
  Future<bool> promptInstall() async {
    final result = await js_util.promiseToFuture<Object?>(
        js_util.callMethod(html.window, '__pwaPrompt', const []));
    final ok = js_util.getProperty(result as Object, 'ok') == true;
    if (ok) {
      installAvailable.value = false;
    }
    return ok;
  }
}

PwaService createPwaService() => PwaServiceWeb();
