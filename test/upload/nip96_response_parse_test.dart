import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/upload/upload_service.dart';
import 'package:nostr_video/services/upload/upload_models.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class _DioFake extends Dio {
  Map<String, dynamic> payload;
  _DioFake(this.payload);
  @override
  Future<Response<T>> post<T>(String path,
      {data,
      Options? options,
      ProgressCallback? onSendProgress,
      CancelToken? cancelToken,
      ProgressCallback? onReceiveProgress}) async {
    onSendProgress?.call(5, 10);
    onSendProgress?.call(10, 10);
    return Response<T>(data: payload as T, requestOptions: RequestOptions());
  }
}

void main() {
  test('parses nip96 JSON', () async {
    final dio = _DioFake({
      'url': 'https://cdn/x.mp4',
      'thumb': 'https://cdn/x.jpg',
      'mime': 'video/mp4',
      'dim': '1080x1920',
      'dur': 21.4,
    });
    final svc = Nip96UploadService(dio);
    final tmp = File('fake'); // path unused by fake
    final res = await svc.uploadFile(tmp, onProgress: (_, __) {});
    expect(res.url, contains('.mp4'));
    expect(res.width, 1080);
    expect(res.height, 1920);
    expect(res.duration, 21.4);
  });
}
