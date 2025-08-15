import 'dart:convert';
import 'package:dio/dio.dart';
import '../../services/keys/key_service.dart';
import 'lightning_models.dart';

abstract class LightningService {
  Future<LnurlPayParams> fetchParamsFromAddress(String address);
  Future<LnurlPayParams> fetchParamsFromLnurl(String lnurlBech32);
  Future<Invoice> requestInvoice({
    required LnurlPayParams params,
    required int amountSats,
    required Map<String, dynamic> zapRequest9734,
    String? comment,
    String? relaysJson,
  });
}

class LnurlLightningService implements LightningService {
  LnurlLightningService(this._dio, this._keys);
  final Dio _dio;
  final KeyService _keys; // ignore: unused_field

  @override
  Future<LnurlPayParams> fetchParamsFromAddress(String address) async {
    final parts = address.split('@');
    if (parts.length != 2) {
      throw Exception('Invalid lightning address');
    }
    final url = Uri.https(parts[1], '/.well-known/lnurlp/${parts[0]}');
    final resp = await _dio.getUri(url);
    final data = resp.data as Map;
    return LnurlPayParams(
      callback: Uri.parse(data['callback'] as String),
      minSendable: data['minimumSendable'] as int,
      maxSendable: data['maximumSendable'] as int,
      nostrPubkey: (data['nostrPubkey'] ?? '') as String?,
    );
  }

  @override
  Future<LnurlPayParams> fetchParamsFromLnurl(String lnurlBech32) async {
    final lower = lnurlBech32.toLowerCase();
    if (!lower.startsWith('lnurl1')) throw Exception('Invalid LNURL');
    const charset = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';
    final five = <int>[];
    for (int i = 7; i < lower.length; i++) {
      final idx = charset.indexOf(lower[i]);
      if (idx == -1) continue;
      five.add(idx);
    }
    final bytes = <int>[];
    var acc = 0, bits = 0;
    for (final v in five) {
      acc = (acc << 5) | v;
      bits += 5;
      if (bits >= 8) {
        bits -= 8;
        bytes.add((acc >> bits) & 0xff);
      }
    }
    final url = Uri.parse(utf8.decode(bytes));
    final resp = await _dio.getUri(url);
    final data = resp.data as Map;
    return LnurlPayParams(
      callback: Uri.parse(data['callback'] as String),
      minSendable: data['minimumSendable'] as int,
      maxSendable: data['maximumSendable'] as int,
      nostrPubkey: (data['nostrPubkey'] ?? '') as String?,
    );
  }

  @override
  Future<Invoice> requestInvoice({
    required LnurlPayParams params,
    required int amountSats,
    required Map<String, dynamic> zapRequest9734,
    String? comment,
    String? relaysJson,
  }) async {
    final msats = amountSats * 1000;
    if (msats < params.minSendable || msats > params.maxSendable) {
      throw Exception('Amount out of range');
    }
    final qp = <String, String>{
      'amount': '$msats',
      'nostr': jsonEncode(zapRequest9734),
      if (comment != null && comment.isNotEmpty) 'comment': comment,
      if (relaysJson != null) 'relays': relaysJson,
    };
    final url = params.callback.replace(queryParameters: qp);
    final resp = await _dio.getUri(url);
    final data = resp.data as Map;
    if (data['status'] == 'ERROR') throw Exception(data['reason'] ?? 'LNURL error');
    final pr = (data['pr'] ?? '') as String;
    if (pr.isEmpty) throw Exception('No invoice');
    return Invoice(pr);
  }
}
