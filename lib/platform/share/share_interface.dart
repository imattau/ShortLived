abstract class ShareShim {
  bool get isSupported;
  Future<bool> share({required String url, String? text, String? title});
}
