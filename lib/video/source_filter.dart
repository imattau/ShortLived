class SourceFilter {
  /// MIME types we explicitly accept.
  static const _allowed = <String>{
    'video/mp4',
    'video/webm',
    'video/ogg',
    'application/x-mpegurl',
    'application/vnd.apple.mpegurl',
  };

  /// Returns true if this looks playable *enough* to try.
  /// Many relays/origins return `application/octet-stream` or omit headers.
  static bool allow({String? contentType, required Uri uri}) {
    final ct = contentType?.toLowerCase().trim();

    // 1) Explicit allow-list.
    if (ct != null && _allowed.contains(ct)) return true;

    // 2) Treat unknown/generic types as *maybe* video; use extension hint.
    final path = uri.path.toLowerCase();
    if (path.endsWith('.mp4') || path.endsWith('.webm') || path.endsWith('.ogg')) {
      return true;
    }
    if (path.endsWith('.m3u8')) {
      // HLS: let the adapter decide with formatHint.
      return true;
    }

    // 3) If we got a video-ish prefix, allow.
    if (ct != null && ct.startsWith('video/')) return true;

    // Otherwise, block.
    return false;
  }
}

