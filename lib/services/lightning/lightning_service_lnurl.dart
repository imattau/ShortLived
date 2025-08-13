import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../nostr/relay_service.dart';
import 'lightning_service.dart';

class LightningServiceLnurl implements LightningService {
  final RelayService relay;
  LightningServiceLnurl(this.relay);

  @override
  Uri buildLnurl(String lud16, int millisats, {String? note}) {
    // Simple deep link used by many wallets; not full LNURL pay flow.
    final qp = {
      'amount': millisats.toString(),
      if (note != null && note.isNotEmpty) 'comment': note,
    };
    return Uri(scheme: 'lightning', path: lud16, queryParameters: qp);
  }

  @override
  Stream<Map<String, dynamic>> listenForZapReceipts(String eventId) {
    // Filter RelayService events for kind 9735 receipts that reference this event
    return relay.events.where((evt) {
      if (evt['kind'] != 9735) return false;
      final tags = (evt['tags'] as List?) ?? const [];
      return tags.any(
          (t) => t is List && t.length >= 2 && t[0] == 'e' && t[1] == eventId);
    });
  }

  Future<void> openWallet(Uri ln) async {
    if (!await launchUrl(ln, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not open wallet');
    }
  }
}
