import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/lightning/lightning_service.dart';
import 'package:dio/dio.dart';
import 'package:nostr_video/services/keys/key_service.dart';

class _DioFakeOk extends Dio {
  final Map<String, dynamic> json;
  _DioFakeOk(this.json);
  @override
  Future<Response<T>> getUri<T>(Uri uri, {Options? options, CancelToken? cancelToken, ProgressCallback? onReceiveProgress}) async {
    return Response<T>(data: json as T, requestOptions: RequestOptions());
  }
}

void main() {
  test('rejects amount outside min/max', () async {
    final s = LnurlLightningService(_DioFakeOk({
      'callback': 'https://cb',
      'minimumSendable': 1000,
      'maximumSendable': 1000000,
    }), _DummyKeys());
    final p = await s.fetchParamsFromAddress('name@example.com');
    expect(() => s.requestInvoice(params: p, amountSats: 0, zapRequest9734: {}), throwsA(isA<Exception>()));
  });
}

class _DummyKeys implements KeyService {
  @override Future<String?> exportNsec() async => null;
  @override Future<String> generate() async => '';
  @override Future<String> importSecret(String nsecOrHex) async => '';
  @override Future<String?> getPrivkey() async => '11'*32;
  @override Future<String?> getPubkey() async => '02'+'a'*66;
}
