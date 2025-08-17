// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import '../web/media_support.dart';

class WebVideoCompat {
  static bool isHls(String url) => url.toLowerCase().contains('.m3u8');
  static bool looksMp4(String url) => url.toLowerCase().contains('.mp4');
  static bool looksWebm(String url) => url.toLowerCase().contains('.webm');
  static bool looksOgg(String url) => url.toLowerCase().contains('.ogg');

  static bool browserCanLikelyPlay(String url) {
    if (!kIsWeb) return true;
    if (isHls(url)) {
      // Allow if HLS MIME is likely supported.
      return mediaSourceIsSupported('application/vnd.apple.mpegurl');
    }
    final v = html.VideoElement();
    if (looksMp4(url)) {
      if (!mediaSourceIsSupported('video/mp4')) return true;
      return v.canPlayType('video/mp4').isNotEmpty;
    }
    if (looksWebm(url)) {
      if (!mediaSourceIsSupported('video/webm')) return true;
      return v.canPlayType('video/webm').isNotEmpty;
    }
    if (looksOgg(url)) {
      if (!mediaSourceIsSupported('video/ogg')) return true;
      return v.canPlayType('video/ogg').isNotEmpty;
    }
    return true;
  }

  static html.VideoElement? createWithCors() {
    if (!kIsWeb) return null;
    final el = html.VideoElement();
    el.crossOrigin = 'anonymous';
    return el;
  }
}
