import 'dart:html' as html; // ignore: avoid_web_libraries_in_flutter
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
    final res = await html.window.callMethod('__pwaPrompt', const []) as Object?;
    final map = res is Map ? Map<String, dynamic>.from(res) : <String, dynamic>{};
    if (map['ok'] == true) {
      installAvailable.value = false;
      return true;
    }
    return false;
  }
}

PwaService createPwaService() => PwaServiceWeb();
