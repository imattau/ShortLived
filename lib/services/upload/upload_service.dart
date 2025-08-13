import '../../data/models/file_meta.dart';

abstract class UploadService {
  Future<FileMeta> uploadVideo(String localPath);
}
