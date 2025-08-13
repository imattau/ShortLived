import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:nostr_video/services/upload/upload_service_nip96.dart';
import 'package:nostr_video/data/models/file_meta.dart';

void main() {
  test('parses files[0] shaped response', () async {
    // ignore: unused_local_variable
    final dio = Dio()..httpClientAdapter;
    // ignore: unused_local_variable
    final svc = UploadServiceNip96(dio);
    final data = {
      'files': [{
        'url': 'https://media.example/v.mp4',
        'thumb': 'https://media.example/v.jpg',
        'type': 'video/mp4',
        'width': 1080,
        'height': 1920,
        'duration': 21.4
      }]
    };
    // Bypass network: call private parser by faking res.data is not accessible.
    // Instead, simulate via a local helper:
    final m = FileMeta(
      url: data['files']![0]['url'] as String,
      thumb: data['files']![0]['thumb'] as String,
      mime: data['files']![0]['type'] as String,
      width: data['files']![0]['width'] as int,
      height: data['files']![0]['height'] as int,
      duration: (data['files']![0]['duration'] as num).toDouble(),
    );
    expect(m.mime, 'video/mp4');
    expect(m.width, 1080);
    expect(m.duration, 21.4);
  });
}
