import 'package:flutter/foundation.dart';
import 'dart:html' as html;

class WebVideoCompat {
  static bool isHls(String url) => url.toLowerCase().contains('.m3u8');
  static bool looksMp4(String url) => url.toLowerCase().contains('.mp4');
  static bool looksWebm(String url) => url.toLowerCase().contains('.webm');

  static bool browserCanLikelyPlay(String url) {
    if (!kIsWeb) return true;
    if (isHls(url)) return true; // handled by hls plugin
    final v = html.VideoElement();
    if (looksMp4(url)) return v.canPlayType('video/mp4').isNotEmpty;
    if (looksWebm(url)) return v.canPlayType('video/webm').isNotEmpty;
    return true;
  }

  static html.VideoElement? createWithCors() {
    if (!kIsWeb) return null;
    final el = html.VideoElement();
    el.crossOrigin = 'anonymous';
    return el;
  }
}
