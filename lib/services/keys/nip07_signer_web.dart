// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js_util' as jsu;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'signer.dart';

class Nip07Signer implements Signer {
  dynamic get _nostr =>
      kIsWeb ? jsu.getProperty(jsu.globalThis, 'nostr') : null;
  bool get available => _nostr != null;

  @override
  Future<String?> getPubkey() async {
    if (!available) return null;
    try {
      final res =
          await jsu.promiseToFuture(jsu.callMethod(_nostr, 'getPublicKey', []));
      return res as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> sign(
      int kind, String content, List<List<String>> tags) async {
    if (!available) return null;
    final created = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final ev = {
      'kind': kind,
      'created_at': created,
      'content': content,
      'tags': tags,
    };
    try {
      final signed =
          await jsu.promiseToFuture(jsu.callMethod(_nostr, 'signEvent', [ev]));
      final obj = jsu.dartify(signed);
      return Map<String, dynamic>.from(obj as Map);
    } catch (_) {
      return null;
    }
  }
}
