import 'package:dio/dio.dart';
import '../../core/config/network.dart';
import '../../data/models/file_meta.dart';
import 'upload_service.dart';

class UploadServiceNip96 implements UploadService {
  final Dio _dio;
  UploadServiceNip96(this._dio);

  @override
  Future<FileMeta> uploadVideo(String localPath) async {
    final file = await MultipartFile.fromFile(localPath, filename: localPath.split('/').last);
    final form = FormData.fromMap({'file': file});
    final res = await _dio.post(NetworkConfig.nip96UploadUrl, data: form);
    final data = res.data;

    // Flexible parsing: look under files[0] or top-level
    Map<String, dynamic>? f;
    if (data is Map && data['files'] is List && data['files'].isNotEmpty) {
      f = Map<String, dynamic>.from(data['files'][0] as Map);
    } else if (data is Map) {
      f = Map<String, dynamic>.from(data);
    } else {
      throw Exception('Unexpected NIP-96 response shape');
    }

    final url   = (f['url'] ?? f['download_url']) as String;
    final thumb = (f['thumb'] ?? f['thumbnail'] ?? '') as String;
    final mime  = (f['type'] ?? f['mime'] ?? 'video/mp4') as String;
    final w     = (f['width'] ?? f['w'] ?? 1080) as int;
    final h     = (f['height'] ?? f['h'] ?? 1920) as int;
    final dur   = (f['duration'] is num) ? (f['duration'] as num).toDouble() : 0.0;

    return FileMeta(url: url, thumb: thumb, mime: mime, width: w, height: h, duration: dur);
  }
}
