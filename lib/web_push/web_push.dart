import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/push_config.dart';

Uint8List base64UrlToBytes(String s) {
  var b64 = s.replaceAll('-', '+').replaceAll('_', '/');
  while (b64.length % 4 != 0) { b64 += '='; }
  return Uint8List.fromList(base64Decode(b64));
}

class WebPushManager {
  static bool get supported =>
      kIsWeb &&
      html.window.navigator.serviceWorker != null &&
      html.Notification.supported;

  /// Registers SW, asks permission, and subscribes with VAPID key.
  static Future<bool> enable() async {
    if (!supported || !PushConfig.isWeb) return false;

    // Register our standalone push SW (separate from flutter_service_worker.js)
    final reg = await html.window.navigator.serviceWorker!.register('sw_push.js');
    await reg.update();

    // Permission
    final permission = await html.Notification.requestPermission();
    if (permission != 'granted') return false;

    // Subscribe
    final sub = await reg.pushManager.subscribe(html.PushSubscriptionOptions(
      userVisibleOnly: true,
      applicationServerKey: base64UrlToBytes(PushConfig.vapidPublicKey),
    ));

    // Send subscription to server
    final body = sub.toJson();
    final resp = await http.post(
      Uri.parse(PushConfig.subscriptionEndpoint),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(body),
    );
    return resp.statusCode >= 200 && resp.statusCode < 300;
  }

  static Future<void> disable() async {
    if (!supported) return;
    final regs = await html.window.navigator.serviceWorker!.getRegistrations();
    for (final r in regs) {
      final sub = await r.pushManager.getSubscription();
      await sub?.unsubscribe(); // server clean-up is optional/manual
    }
  }
}
