import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/lightning/lightning_service.dart';
import 'package:dio/dio.dart';
import 'package:nostr_video/services/keys/key_service.dart';

class _DioFakeOk extends DioMixin implements Dio {
  _DioFakeOk(this.json) {
    options = BaseOptions();
    httpClientAdapter = _FakeAdapter();
  }

  final Map<String, dynamic> json;

  @override
  final Interceptors interceptors = Interceptors();

  @override
  Future<Response<T>> getUri<T>(Uri uri,
      {Options? options,
      CancelToken? cancelToken,
      Object? data,
      ProgressCallback? onReceiveProgress}) async {
    return Response<T>(
        data: json as T, requestOptions: RequestOptions(path: uri.toString()));
  }
}

class _FakeAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    return ResponseBody.fromString('', 200);
  }
}

void main() {
  test('rejects amount outside min/max', () async {
    final s = LnurlLightningService(
        _DioFakeOk({
          'callback': 'https://cb',
          'minimumSendable': 1000,
          'maximumSendable': 1000000,
        }),
        _DummyKeys());
    final p = await s.fetchParamsFromAddress('name@example.com');
    expect(() => s.requestInvoice(params: p, amountSats: 0, zapRequest9734: {}),
        throwsA(isA<Exception>()));
  });
}

class _DummyKeys implements KeyService {
  @override
  Future<String?> exportNsec() async => null;
  @override
  Future<String> generate() async => '';
  @override
  Future<String> importSecret(String nsecOrHex) async => '';
  @override
  Future<String?> getPrivkey() async => '11' * 32;
  @override
  Future<String?> getPubkey() async => '02${'a' * 66}';
}
