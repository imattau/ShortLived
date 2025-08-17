class WebVideoCompat {
  static bool isHls(String url) => url.toLowerCase().contains('.m3u8');
  static bool looksMp4(String url) => url.toLowerCase().contains('.mp4');
  static bool looksWebm(String url) => url.toLowerCase().contains('.webm');
  static bool looksOgg(String url) => url.toLowerCase().contains('.ogg');

  static bool browserCanLikelyPlay(String url) => true;
  static dynamic createWithCors() => null;
}
