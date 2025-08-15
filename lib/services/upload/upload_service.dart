import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/config/network.dart';
import 'upload_models.dart';

abstract class UploadService {
  Future<UploadResult> uploadFile(
    File file, {
    required void Function(int sent, int total) onProgress,
  });
}

class Nip96UploadService implements UploadService {
  Nip96UploadService(this._dio);
  final Dio _dio;

  @override
  Future<UploadResult> uploadFile(File file, {required void Function(int sent, int total) onProgress}) async {
    final url = NetworkConfig.nip96UploadUrl;
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last),
    });

    late Response resp;
    try {
      resp = await _dio.post(
        url,
        data: form,
        onSendProgress: onProgress,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {'Accept': 'application/json'},
        ),
      );
    } on DioException catch (e) {
      final msg = e.type == DioExceptionType.unknown
          ? 'Upload failed. If this is the web build, check CORS on your NIP-96 host.'
          : 'Upload failed: ${e.message}';
      throw Exception(msg);
    }

    final data = resp.data as Map;
    String getS(String k) => (data[k] ?? '').toString();
    final dim = getS('dim').split('x');
    final w = int.tryParse(dim.isNotEmpty ? dim[0] : '0') ?? 0;
    final h = int.tryParse(dim.length > 1 ? dim[1] : '0') ?? 0;
    final dur = double.tryParse(data['dur']?.toString() ?? '0') ?? 0.0;

    return UploadResult(
      url: getS('url'),
      thumb: getS('thumb'),
      mime: getS('mime'),
      width: w,
      height: h,
      duration: dur,
    );
  }
}
