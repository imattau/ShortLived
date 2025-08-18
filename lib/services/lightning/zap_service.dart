import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/di/locator.dart';
import '../../data/models/post.dart';
import '../nostr/relay_service.dart';
import '../nostr/metadata_service.dart';
import 'lightning_service.dart';
import '../keys/key_service.dart';

/// Orchestrates NIP-57 zap flow: build zap request, request LNURL invoice,
/// and attempt to open a wallet to pay it.
class ZapService {
  ZapService._();
  static final ZapService instance = ZapService._();

  Future<void> zap({
    required Post post,
    required int amountSats,
    String? comment,
  }) async {
    // 1) Determine lightning address or LNURL for the recipient.
    final meta = Locator.I.tryGet<MetadataService>()?.get(post.author.pubkey);
    final addr = meta?.lud16;
    final lnurl = meta?.lud06;
    if ((addr == null || addr.isEmpty) && (lnurl == null || lnurl.isEmpty)) {
      throw Exception('No lightning address');
    }

    // 2) Build zap request event (kind 9734).
    final relay = Locator.I.get<RelayService>();
    final zapReq = await relay.buildZapRequest(
      recipientPubkey: post.author.pubkey,
      eventId: post.id,
      content: comment ?? '',
      amountMsat: amountSats * 1000,
    );

    // 3) Request an invoice via LNURL.
    final lightning = Locator.I.tryGet<LightningService>() ??
        LnurlLightningService(Dio(), Locator.I.get<KeyService>());
    final params = (addr != null && addr.isNotEmpty)
        ? await lightning.fetchParamsFromAddress(addr)
        : await lightning.fetchParamsFromLnurl(lnurl!);
    final inv = await lightning.requestInvoice(
      params: params,
      amountSats: amountSats,
      zapRequest9734: zapReq,
      comment: comment != null && comment.isNotEmpty ? comment : null,
    );

    // 4) Try to open wallet; fallback to clipboard.
    final uri = Uri.parse('lightning:${inv.bolt11}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await Clipboard.setData(ClipboardData(text: inv.bolt11));
    }
  }
}
